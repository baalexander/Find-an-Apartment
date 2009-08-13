#import <UIKit/UIKit.h>
// Must include libxml2.2.dylib for <libxml/tree.h> to work. To do so:
// -add the file to your Frameworks from here: /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/usr/lib
// -set the path Header Search Paths under Build: /Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS3.0.sdk/usr/include/libxml2
#import <libxml/tree.h>

#import "XmlElement.h"


@class XmlParser;

// Protocol for the parser to communicate with its delegate.
@protocol ParserDelegate <NSObject>
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(XmlParser *)parser;
// Called by the parser in the case of an error.
- (void)parser:(XmlParser *)parser didFailWithError:(NSError *)error;
// Called by the parser when a new element is to be added to the item
- (void)parser:(XmlParser *)parser addXmlElement:(XmlElement *)xmlElement;
// Called by the parser when a new item has began being parsed
- (void)parserDidBeginItem:(XmlParser *)parser;
// Called by the parser when the current item has finished being parsed
- (void)parserDidEndItem:(XmlParser *)parser;
@end


// This approach to parsing uses NSURLConnection to asychronously retrieve the XML data. libxml's SAX parsing supports chunked parsing, with no requirement for the chunks to be discrete blocks of well formed XML. The primary purpose of this class is to start the download, configure the parser with a set of C callback functions, and pass downloaded data to it. In addition, the class maintains a number of state variables for the parsing.
@interface XmlParser : NSOperation
{
    @private
        //Delegate to call back parsed information
        id <ParserDelegate> delegate_;
        // Reference to the libxml parser context
        xmlParserCtxtPtr context_;
        // Handles asynchronous retrieval of the XML
        NSURLConnection *connection_;
        // Overall state of the parser, used to exit the run loop.
        BOOL done_;
        // State variable used to determine whether or not to ignore a given XML element
        BOOL parsingAnItem_;
        //URL to download and parse
        NSURL *url_;
        // The following state variables deal with getting character data from XML elements. This is a potentially expensive 
        // operation. The character data in a given element may be delivered over the course of multiple callbacks, so that
        // data must be appended to a buffer. The optimal way of doing this is to use a C string buffer that grows exponentially.
        // When all the characters have been delivered, an NSString is constructed and the buffer is reset.
        BOOL storingCharacters_;
        NSMutableData *characterBuffer_;
        //Element name and length to signify new item to parse
        const char *itemDelimiter_;
        NSUInteger itemDelimiterLength_;
        //Holds XML results for each element
        XmlElement *xmlElement_;
}

@property (nonatomic, assign) id <ParserDelegate> delegate;
@property (nonatomic, assign) const char* itemDelimiter;
@property (nonatomic, assign) NSUInteger itemDelimiterLength;
@property (nonatomic, retain) NSURL *url;

@end
