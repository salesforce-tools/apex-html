/**
 * Created by Derek Wiers on 2019-04-07.
 */
@IsTest(IsParallel=true)
private class HtmlTest {

    private static testMethod void constructorTest() {
        Html test = new Html('tag');
        System.assertEquals('<tag>\n</tag>', String.valueOf(test));

        Html test2 = new Html('tag', new List<Html> {test});
        System.assertEquals('<tag>\n  <tag>\n  </tag>\n</tag>', String.valueOf(test2));

        test2 = new Html('tag', test);
        System.assertEquals('<tag>\n  <tag>\n  </tag>\n</tag>', String.valueOf(test2));

        test2 = new Html('tag', 'test string');
        System.assertEquals('<tag>\n  test string\n</tag>', String.valueOf(test2));

        test2 = new Html('tag', true);
        System.assertEquals('<tag/>', String.valueOf(test2));
    }

    private static testMethod void addTest() {
        Html test = new Html('tag')
            .add('String')
            .add(new Html('p', 'Inner paragraph'))
            .add(new List<Html> {new Html('div')});
        System.assertEquals('<tag>\n  String\n  <p>\n    Inner paragraph\n  </p>\n  <div>\n  </div>\n</tag>', String.valueOf(test));
    }

    private static testMethod void addAttributesTest() {
        Html test = new Html('tag')
            .addAttributes(new Map<String, String> {'att1' => 'initial value', 'att2' => '2nd val'});
        // I know maps don't guarantee order but this has worked every time I've run this so far...
        // I'll add another possible string to compare to if this starts failing.
        System.assertEquals('<tag att1="initial value" att2="2nd val">\n</tag>', String.valueOf(test));

        // Test the added attribute by overriding an existing key
        test.addAttribute('att1', 'overridden value');
        System.assertEquals('<tag att1="overridden value" att2="2nd val">\n</tag>', String.valueOf(test));
    }

    private static testMethod void shortcutMethodsTest() {
        // unstyled elements
        System.assertEquals('<p>\n  test\n</p>', String.valueOf(Html.p('test')));
        System.assertEquals('<h3>\n  test\n</h3>', String.valueOf(Html.h3('test')));
        System.assertEquals('<html>\n</html>', String.valueOf(Html.base()));
        System.assertEquals('<body>\n</body>', String.valueOf(Html.body()));
        System.assertEquals('<tr>\n</tr>', String.valueOf(Html.tr()));
        System.assertEquals('<br/>', String.valueOf(Html.br()));

        // styled elements
        System.assertEquals('<table style="border-collapse: collapse;">\n</table>', String.valueOf(Html.table()));
        System.assertEquals('<th style="border: 1px solid black; padding: 2px 10px;">\n</th>', String.valueOf(Html.th()));
        System.assertEquals('<td style="border: 1px solid black; padding: 2px 10px;">\n</td>', String.valueOf(Html.td()));
    }
}