#import "XmlParser.h"
#import <libxml/tree.h>


// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void    endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void    charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;


@interface XmlParser ()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, assign) BOOL parsingAnItem;
@property (nonatomic, assign) BOOL storingCharacters;
@property (nonatomic, retain) NSMutableData *characterBuffer;
// Main thread functions
- (void)parseStarted;
- (void)parseEnded;
- (void)parseError:(NSError *)error;
- (void)itemBegan;
- (void)itemEnded;
- (void)addElementAndValue:(NSDictionary *)elementAndValueMap;
// Detached thread functions
- (void)downloadAndParse:(NSURL *)url;
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length;
@end


@implementation XmlParser

@synthesize delegate = delegate_;
@synthesize connection = connection_;
@synthesize done = done_;
@synthesize parsingAnItem = parsingAnItem_;
@synthesize storingCharacters = storingCharacters_;
@synthesize characterBuffer = characterBuffer_;
@synthesize itemDelimiter = itemDelimiter_;
@synthesize itemDelimiterLength = itemDelimiterLength_;


#pragma mark -
#pragma mark XmlParser (Initialize/Dealloc)

- (id)init
{    
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (void)dealloc
{
    //TODO: Dealloc everything you can!
    [super dealloc];
}


#pragma mark -
#pragma mark XmlParser (Main thread functions)

- (void)startWithUrl:(NSURL *)url withItemDelimeter:(const char *)itemDelimiter
{
    [self setItemDelimiter:itemDelimiter];
    //Adds 1 to itemDelimeter length to handle the null character ending
    [self setItemDelimiterLength:strlen(itemDelimiter) + 1];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}

- (void)addElementAndValue:(NSDictionary *)elementAndValueMap
{
    [[self delegate] parser:self addElement:[elementAndValueMap objectForKey:@"element"] withValue:[elementAndValueMap objectForKey:@"value"]];
}

- (void)itemBegan
{
    [[self delegate] parserDidBeginItem:self];
}

- (void)itemEnded
{
    [[self delegate] parserDidEndItem:self];
}

- (void)parseStarted
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)parseEnded
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] parserDidEndParsingData:self];
}

- (void)parseError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[self delegate] parser:self didFailWithError:error];
}


#pragma mark -
#pragma mark XmlParser (Detached thread functions)

/*
 This method is called on a secondary thread by the superclass. We have asynchronous work to do here with downloading and parsing data, so we will need a run loop to prevent the thread from exiting before we are finished.
 */
- (void)downloadAndParse:(NSURL *)url
{
    NSAutoreleasePool *downloadAndParsePool = [[NSAutoreleasePool alloc] init];
    
    [self setDone:NO];
    [self setCharacterBuffer:[NSMutableData data]];
    
    //Begins downloading URL
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self setConnection:[[NSURLConnection alloc] initWithRequest:request delegate:self]];
    
    [self performSelectorOnMainThread:@selector(parseStarted) withObject:nil waitUntilDone:NO];
    
    // This creates a context for "push" parsing in which chunks of data that are not "well balanced" can be passed
    // to the context for streaming parsing. The handler structure defined above will be used for all the parsing. 
    // The second argument, self, will be passed as user data to each of the SAX handlers. The last three arguments
    // are left blank to avoid creating a tree in memory.
    context_ = xmlCreatePushParserCtxt(&simpleSAXHandlerStruct, self, NULL, 0, NULL);
    
    //Wait until downloading and parsing has finished
    if ([self connection] != nil)
    {
        do
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        while (![self done]);
    }
    
    // Release resources used only in this thread.
    xmlFreeParserCtxt(context_);
    [self setCharacterBuffer:nil];
    [self setConnection:nil];
    [downloadAndParsePool release];
    downloadAndParsePool = nil;
}

/*
 Character data is appended to a buffer until the current element ends.
 */
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length
{
    [[self characterBuffer] appendBytes:charactersFound length:length];
}


#pragma mark -
#pragma mark NSURLConnection

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self setDone:YES];
    [self performSelectorOnMainThread:@selector(parseError:) withObject:error waitUntilDone:NO];
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Process the downloaded chunk of data.
    xmlParseChunk(context_, (const char *)[data bytes], [data length], 0);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //[self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
    // Signal the context that parsing is complete by passing "1" as the last parameter.
    xmlParseChunk(context_, NULL, 0, 1);
    context_ = NULL;
    [self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
    // Set the condition which ends the run loop.
    [self setDone:YES];
}

@end


#pragma mark -
#pragma mark SAX Parsing Callbacks

/*
 This callback is invoked when the parser finds the beginning of a node in the XML. For this application,
 out parsing needs are relatively modest - we need only match the node name. An "item" node is a record of
 data about a song. In that case we create a new Song object. The other nodes of interest are several of the
 child nodes of the Song currently being parsed. For those nodes we want to accumulate the character data
 in a buffer. Some of the child nodes may use a namespace prefix. 
 */
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, 
                            int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes)
{
    XmlParser *parser = (XmlParser *)ctx;
    
    // The second parameter to strncmp is the name of the element, which we known from the XML schema of the feed.
    // The third parameter to strncmp is the number of characters in the element name, plus 1 for the null terminator.
    if (prefix == NULL
        && strncmp((const char *)localname, [parser itemDelimiter], [parser itemDelimiterLength]) == 0)
        //&& strncmp((const char *)localname, "property", 9) == 0)
    {
        [parser performSelectorOnMainThread:@selector(itemBegan) withObject:nil waitUntilDone:NO];
        [parser setParsingAnItem:YES];
    }
    else if (prefix == NULL
             && [parser parsingAnItem] == YES)
    {
        [parser setStoringCharacters:YES];
    }
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void    endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI)
{
    XmlParser *parser = (XmlParser *)ctx;
    if ([parser parsingAnItem] == NO)
    {
        return;
    }
    if (prefix == NULL)
    {
        if (strncmp((const char *)localname, [parser itemDelimiter], [parser itemDelimiterLength]) == 0)
        {
            [parser performSelectorOnMainThread:@selector(itemEnded) withObject:nil waitUntilDone:NO];
            [parser setParsingAnItem:NO];
        }
        else
        {
            NSString *element = [[NSString alloc] initWithUTF8String:(const char *)localname];
            NSString *value = [[NSString alloc] initWithData:[parser characterBuffer] encoding:NSUTF8StringEncoding];
            NSDictionary *elementAndValueMap = [[NSDictionary alloc] initWithObjectsAndKeys:element, @"element", value, @"value", nil];
            [element release];
            [value release];
            [parser performSelectorOnMainThread:@selector(addElementAndValue:) withObject:elementAndValueMap waitUntilDone:NO];
            [elementAndValueMap release];
        }
    }
    
    [[parser characterBuffer] setLength:0];
    [parser setStoringCharacters:NO];
}

/*
 This callback is invoked when the parser encounters character data inside a node. The parser class determines how to use the character data.
 */
static void    charactersFoundSAX(void *ctx, const xmlChar *ch, int len)
{
    XmlParser *parser = (XmlParser *)ctx;
    // A state variable, "storingCharacters", is set when nodes of interest begin and end. 
    // This determines whether character data is handled or ignored. 
    if ([parser storingCharacters] == NO)
    {
        return;
    }
    [parser appendCharacters:(const char *)ch length:len];
}

/*
 A production application should include robust error handling as part of its parsing implementation.
 The specifics of how errors are handled depends on the application.
 */
static void errorEncounteredSAX(void *ctx, const char *msg, ...)
{
    //TODO: Call parseError on main thread with initialized error message using *msg
    printf(msg);
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
NULL,                       /* internalSubset */
NULL,                       /* isStandalone   */
NULL,                       /* hasInternalSubset */
NULL,                       /* hasExternalSubset */
NULL,                       /* resolveEntity */
NULL,                       /* getEntity */
NULL,                       /* entityDecl */
NULL,                       /* notationDecl */
NULL,                       /* attributeDecl */
NULL,                       /* elementDecl */
NULL,                       /* unparsedEntityDecl */
NULL,                       /* setDocumentLocator */
NULL,                       /* startDocument */
NULL,                       /* endDocument */
NULL,                       /* startElement*/
NULL,                       /* endElement */
NULL,                       /* reference */
charactersFoundSAX,         /* characters */
NULL,                       /* ignorableWhitespace */
NULL,                       /* processingInstruction */
NULL,                       /* comment */
NULL,                       /* warning */
errorEncounteredSAX,        /* error */
NULL,                       /* fatalError //: unused error() get all the errors */
NULL,                       /* getParameterEntity */
NULL,                       /* cdataBlock */
NULL,                       /* externalSubset */
XML_SAX2_MAGIC,             //
NULL,
startElementSAX,            /* startElementNs */
endElementSAX,              /* endElementNs */
NULL,                       /* serror */
};
