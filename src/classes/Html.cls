/**
 * Created by Derek Wiers on 2019-04-06.
 * Wrapper around HTML tags, specifically meant for Emails (inlines CSS for that reason)
 */

public without sharing class Html {


    /************************** "Shortcut" methods **************************/

    // These shortcut methods are a way of making client code less verbose, and in some cases, add standard styling for
    // consistency.  As I've written one of these in the past, I've noticed that it's really easy to make these
    // commonly-used tags hard to read unless you have an extremely terse but still readable way to construct them,
    // so here we are.

    /**
     * <p> element
     *
     * @param contents Inner HTML contents
     *
     * @return HTML <p> element with contents
     */
    public static Html p(String contents) {
        return new Html('p', contents);
    }

    /**
     * <h3> element
     *
     * @param contents Inner HTML contents
     *
     * @return HTML <h3> element with contents
     */
    public static Html h3(String contents) {
        return new Html('h3', contents);
    }

    /**
     * <html> element
     *
     * @return Empty <html></html> element
     */
    public static Html base() {
        return new Html('html');
    }

    /**
     * <body> element
     *
     * @return Empty <body></body> element
     */
    public static Html body() {
        return new Html('body');
    }

    /**
     * <table> element
     *
     * @return Empty <table> element with some standard styling
     */
    public static Html table() {
        return new Html('table')
            .addAttribute('style', 'border-collapse: collapse;');
    }

    /**
     * <tr> element (Table Row)
     *
     * @return Empty <tr> element
     */
    public static Html tr() {
        return new Html('tr');
    }

    /**
     * <th> element with standard styling
     *
     * @return Empty <th> element with some standard styling
     */
    public static Html th() {
        return new Html('th')
            .addAttribute('style', 'border: 1px solid black; padding: 2px 10px;');
    }

    /**
     * <td> element with standard styling
     *
     * @return Empty <td> element with some standard styling
     */
    public static Html td() {
        return new Html('td')
            .addAttribute('style', 'border: 1px solid black; padding: 2px 10px;');
    }

    /**
     * <br/> element
     *
     * @return Self closing <br/> element
     */
    public static Html br() {
        return new Html('br', true);
    }

    /************************** Class Definition **************************/

    // Constant to define 1 level of indentation.
    private static final String INDENT_STRING = '  ';

    private String tag;

    // <tag att1="A" att2="B"> would map to {"att1" => "A", "att2" => "B"}
    private Map<String, String> attributes = new Map<String, String>();

    // Can be a mix of Strings or Html objects
    private List<Object> contents = new List<Object> ();

    // Note: Self-closing elements don't render inner HTML elements but do render attributes if any.
    private Boolean selfClosing = false;

    /************************** Constructors **************************/

    /**
     * Constructor with a list of child HTMl elements
     *
     * @param tag Tag of element
     * @param contents Inner HTML elements
     */
    public Html(String tag, List<Html> contents) {
        this.tag = tag;
        this.contents = contents;
    }

    /**
     * Constructor with a single HTML child
     *
     * @param tag Tag of element
     * @param contents Inner HTML element
     */
    public Html(String tag, Html contents) {
        this.tag = tag;
        this.contents = new List<Object> {contents};
    }

    /**
     * Constructor with plaintext as child - note that the string is escaped in the rendered HTML.
     *
     * @param tag Tag of element
     * @param contents Plain text contents (Client code need not escape - it is escaped inside the Html class)
     */
    public Html(String tag, String contents) {
        this.tag = tag;
        this.contents = new List<Object> {contents.escapeHtml4()};
    }

    /**
     * Constructor for an empty, non-self-closing element
     *
     * @param tag Tag of element
     */
    public Html(String tag) {
        this.tag = tag;
    }

    /**
     * Constructor for self-closing elements
     *
     * @param tag Tag of element
     * @param selfClosing True if we need the element to be self-closing; false otherwise
     */
    public Html(String tag, Boolean selfClosing) {
        this.tag = tag;
        this.selfClosing = selfClosing;
    }

    /************************** Instance Methods **************************/
    /**
     * Adds the given Html element into the inner contents of the current element.
     *
     * @param element desired inner HTML to append
     *
     * @return The element after the contents are added.
     */
    public Html add(Html element) {
        this.contents.add(element);
        return this;
    }

    /**
     * Adds the given Html elements into the inner contents of the current element.
     *
     * @param elements desired inner HTML to append
     *
     * @return The element after the contents are added.
     */
    public Html add(List<Html> elements) {
        this.contents.addAll(elements);
        return this;
    }

    /**
     * Adds the given plaintext into the inner contents of the current element
     *
     * @param element the desired string to append (will be escaped in the Html class)
     *
     * @return The element after the contents are added.
     */
    public Html add(String element) {
        this.contents.add(element.escapeHtml4());
        return this;
    }

    /**
     * Adds the given attributes into the tag of the current element
     *
     * @param attributes key-value map of desired attributes
     *
     * @return The element after the attributes are added.
     */
    public Html addAttributes(Map<String, String> attributes) {
        this.attributes.putAll(attributes);
        return this;
    }

    /**
     * Adds the given attribute into the tag of the current element
     *
     * @param key The name of the attribute
     * @param value The value of the attribute
     *
     * @return The element after the attribute has been added.
     */
    public Html addAttribute(String key, String value) {
        this.attributes.put(key, value);
        return this;
    }


    /**
     * Overrides the Object.toString() method to compile the HTML just by using String.valueOf(htmlObject)
     *
     * @return compiled HTML in string form.
     */
    public override String toString() {
        return compileHtml(0);
    }

    /**
     * Recursively compile the current HTML element and all its contents, adding 1 level of indentation every time.
     *
     * @param indent Number of units of indentation that the current element should be at
     *
     * @return The compiled HTML in string form
     */
    private String compileHtml(Integer indent) {
        String output = getIndent(indent) + renderTag();
        if (!selfClosing) {
            if (contents.size() > 0) {
                for(Object element : contents) {
                    if (element instanceof String) {
                        output += '\n' + getIndent(indent + 1) + String.valueOf(element).replace('\n', '\n' + getIndent(indent + 2));
                    } else if (element instanceof Html) {
                        Html htmlElement = (Html)element;
                        output += '\n' + htmlElement.compileHtml(indent +1);
                    }
                }
            }
            output += '\n' + getIndent(indent) + '</' + tag + '>';
        }
        return output;
    }

    /**
     * Using the INDENT_STRING and the number of indentation levels, get a string that represents the desired indentation
     *
     * @param indent Indentation level
     *
     * @return INDENT_STRING times the number of indentation levels
     */
    private String getIndent(Integer indent) {
        String output = '';
        for (Integer i = 0; i < indent; i++) {
            output += INDENT_STRING;
        }
        return output;
    }

    /**
     * Renders the current element's tag to a String.  Includes all attributes and the '/' if self closing.
     *
     * @return The String representation of the current element's tag.
     */
    private String renderTag() {
        String output = '<' + tag;
        if (attributes.size() > 0) {
            for (String attribute : attributes.keySet()) {
                output += ' ' + attribute + '="' + attributes.get(attribute) + '"';
            }
        }
        if (selfClosing) {
            output += '/';
        }
        output += '>';
        return output;
    }
}