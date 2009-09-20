#import "XmlParser.h"
#import <libxml/tree.h>


// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

// Forward reference. The structure is defined in full at the end of the file.
static xmlSAXHandler simpleSAXHandlerStruct;


@interface XmlParser ()
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, assign) BOOL done;
@property (nonatomic, assign) BOOL parsingAnItem;
@property (nonatomic, assign) BOOL storingCharacters;
@property (nonatomic, retain) NSMutableData *characterBuffer;
@property (nonatomic, retain) XmlElement *xmlElement;
- (void)parseEnded;
- (void)parseError:(NSError *)error;
- (void)itemBegan;
- (void)itemEnded;
- (void)addXmlElement:(XmlElement *)xmlElement;
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length;
@end


@implementation XmlParser

@synthesize delegate = delegate_;
@synthesize connection = connection_;
@synthesize done = done_;
@synthesize url = url_;
@synthesize parsingAnItem = parsingAnItem_;
@synthesize storingCharacters = storingCharacters_;
@synthesize characterBuffer = characterBuffer_;
@synthesize itemDelimiter = itemDelimiter_;
@synthesize itemDelimiterLength = itemDelimiterLength_;
@synthesize xmlElement = xmlElement_;


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
    [url_ release];

    [super dealloc];
}


#pragma mark -
#pragma mark XmlParser

- (void)addXmlElement:(XmlElement *)xmlElement
{
    [[self delegate] parser:self addXmlElement:xmlElement];
}

- (void)itemBegan
{
    [[self delegate] parserDidBeginItem:self];
}

- (void)itemEnded
{
    [[self delegate] parserDidEndItem:self];
}

- (void)parseEnded
{
    [[self delegate] parserDidEndParsingData:self];
}

- (void)parseError:(NSError *)error
{
    [[self delegate] parser:self didFailWithError:error];
}

- (void)setItemDelimiter:(const char*)itemDelimiter
{
    itemDelimiter_ = itemDelimiter;
    [self setItemDelimiterLength:strlen([self itemDelimiter]) + 1];
}

/*
 Character data is appended to a buffer until the current element ends.
 */
- (void)appendCharacters:(const char *)charactersFound length:(NSInteger)length
{
    [[self characterBuffer] appendBytes:charactersFound length:length];
}


#pragma mark -
#pragma mark NSOperation

- (void)main
{
    NSAutoreleasePool *downloadAndParsePool = [[NSAutoreleasePool alloc] init];
    
    [self setDone:NO];
    NSMutableData *characterBuffer = [[NSMutableData alloc] init];
    [self setCharacterBuffer:characterBuffer];
    [characterBuffer release];
    
    //Begins downloading URL
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[self url]];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request release];
    [self setConnection:connection];
    [connection release];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
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

        //Cancels connection in case DONE was set to true before finished downloading. For example, when navigating back during downloading.
        [[self connection] cancel];
        [self setConnection:nil];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // Release resources used only in this thread.
    xmlFreeParserCtxt(context_);
    context_ = NULL;
    [self setCharacterBuffer:nil];
    [downloadAndParsePool release];
    downloadAndParsePool = nil;
}

- (void)cancel
{
    [self setDone:YES];
}


#pragma mark -
#pragma mark NSURLConnection

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (![self done])
    {
        [self setDone:YES];
        [self performSelectorOnMainThread:@selector(parseError:) withObject:error waitUntilDone:NO];        
    }
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (![self done])
    {
        // Process the downloaded chunk of data.
        xmlParseChunk(context_, (const char *)[data bytes], [data length], 0);        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (![self done])
    {        
        // Signal the context that parsing is complete by passing "1" as the last parameter.
        xmlParseChunk(context_, NULL, 0, 1);
        //Sample code has context_ = NULL here. But the free up context function call happens after this and would happen on a NULL pointer. Won't cause an error, but appears to cause memory leaks.
        [self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];

        // Set the condition which ends the run loop.
        [self setDone:YES];
    }
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
        XmlElement *xmlElement = [[XmlElement alloc] init];
        [parser setXmlElement:xmlElement];
        [xmlElement release];
        
        NSString *localnameString = [[NSString alloc] initWithUTF8String:(const char *)localname];
        [[parser xmlElement] setName:localnameString];
        [localnameString release];
        
        [parser setStoringCharacters:YES];
    }
    
    //Gets attributes
    NSMutableDictionary *attributeDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSInteger attributeCounter = 0; attributeCounter < nb_attributes; attributeCounter++)
    {
        //The start of the attribute in the attributes array. There are 5 attribute elements in the array PER attribute.
        NSInteger attributeStartIndex = attributeCounter * 5;
        
        //Index of name
        static NSInteger nameIndex = 0;
        //Beginning index of value
        static NSInteger valueIndex = 3;
        
        // The beginning of the attribute value starts at index 3 in the array.
        // The end of the attribute value starts at index 4 in the array.
        const char *valueBegin = (const char *)attributes[attributeStartIndex + valueIndex];
        const char *valueEnd = (const char *)attributes[attributeStartIndex + valueIndex + 1];
        
        if (valueBegin && valueEnd)
        {
            const char *localAttributeName = (const char *)attributes[attributeStartIndex + nameIndex];
            NSString *localAttributeNameString = [[NSString alloc] initWithUTF8String:(const char *)localAttributeName];
            
            // Not sure why getting the attribute value is so convoluted.
            NSString *value = [[NSString alloc] initWithBytes:attributes[attributeStartIndex + valueIndex] length:(strlen(valueBegin) - strlen(valueEnd)) encoding:NSUTF8StringEncoding];
            [attributeDictionary setObject:value forKey:localAttributeNameString];
            [localAttributeNameString release];
            [value release];
        }
    }
    [[parser xmlElement] setAttributes:attributeDictionary];
}

/*
 This callback is invoked when the parse reaches the end of a node. At that point we finish processing that node,
 if it is of interest to us. For "item" nodes, that means we have completed parsing a Song object. We pass the song
 to a method in the superclass which will eventually deliver it to the delegate. For the other nodes we
 care about, this means we have all the character data. The next step is to create an NSString using the buffer
 contents and store that with the current Song object.
 */
static void endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI)
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
            NSString *value = [[NSString alloc] initWithData:[parser characterBuffer] encoding:NSUTF8StringEncoding];
            [[parser xmlElement] setValue:value];
            [value release];
            [parser performSelectorOnMainThread:@selector(addXmlElement:) withObject:[parser xmlElement] waitUntilDone:NO];
        }
    }
    
    [parser setXmlElement:nil];
    [[parser characterBuffer] setLength:0];
    [parser setStoringCharacters:NO];
}

/*
 This callback is invoked when the parser encounters character data inside a node. The parser class determines how to use the character data.
 */
static void charactersFoundSAX(void *ctx, const xmlChar *ch, int len)
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
    // printf(msg);
//    NSString *message = [[NSString alloc] initWithCString:msg];
//    DebugLog(message);
//    [message release];
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
