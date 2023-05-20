// ignore_for_file: prefer_const_constructors

import 'package:biton_ai/common/extensions/num_ext.dart';
import 'package:biton_ai/common/extensions/string_ext.dart';
import 'package:biton_ai/common/extensions/widget_ext.dart';
import 'package:biton_ai/widgets/resultsList.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';

import '../common/themes/app_colors.dart';

class HtmlEditorViewer extends StatefulWidget {
  const HtmlEditorViewer(this.html, {Key? key}) : super(key: key);

  final String html;

  @override
  _HtmlEditorViewerState createState() => _HtmlEditorViewerState();
}

class _HtmlEditorViewerState extends State<HtmlEditorViewer>
    with SingleTickerProviderStateMixin {
  String result = '';
  final HtmlEditorController controller = HtmlEditorController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('START: widget.text()');
    print('widget.text ${widget.html}');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var roundShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        bottomLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
    );

    return Column(
      children: [
        buildTabBarLabel().centerRight,
        Expanded(
          child: Material(
            elevation: 3,
            shape: roundShape,
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                //~ Html editor:
                Card(
                  margin: EdgeInsets.zero,
                  shape: roundShape,
                  child: buildHtmlEditor(),
                ),
                //~ Code viewer:
                Stack(
                  children: [
                    Card(
                      shape: roundShape,
                      margin: EdgeInsets.zero,
                      child: SelectableText(
                        result,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    buildCopyButton(context, true, result)
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  HtmlEditor buildHtmlEditor() {
    return HtmlEditor(
      controller: controller,
      htmlEditorOptions: HtmlEditorOptions(
        hint: 'Your text here...',
        initialText: widget.html,
        shouldEnsureVisible: true,
      ),
      htmlToolbarOptions: HtmlToolbarOptions(
        toolbarType: ToolbarType.nativeScrollable,
        defaultToolbarButtons: [
          StyleButtons(style: true),
          // Todo fix dropdown scroll for fontSize:
          FontSettingButtons(
            fontSize: true,
            fontName: false,
            fontSizeUnit: false,
          ),
          FontButtons(
              clearAll: false,
              subscript: false,
              strikethrough: false,
              superscript: false),
          ListButtons(listStyles: false),
          // ColorButtons(highlightColor: false),
          ParagraphButtons(
            textDirection: true,
            lineHeight: false,
            caseConverter: false,
            alignCenter: true,
            alignJustify: false,
            decreaseIndent: false,
            increaseIndent: false,
          ),
          InsertButtons(
              video: false,
              audio: false,
              table: false,
              hr: false,
              otherFile: false,
              picture: false,
              link: true),
        ],
      ),
      otherOptions: const OtherOptions(height: 550),
      callbacks: Callbacks(
        onChangeContent: (_) async {
          var txt = await controller.getText();
          if (txt.contains('src=\"data:')) {
            txt =
                '<text removed due to base-64 data, displaying the text could cause the app to crash>';
          }
          result = txt;
          setState(() {});
        },
      ),
      plugins: [
        SummernoteAtMention(
            getSuggestionsMobile: (String value) {
              var mentions = <String>['test1', 'test2', 'test3'];
              return mentions.where((element) => element.contains(value)).toList();
            },
            mentionsWeb: ['test1', 'test2', 'test3'],
            onSelect: (String value) {
              print(value);
            }),
      ],
    );
  }

  SizedBox buildTabBarLabel() {
    return SizedBox(
      width: 200,
      child: Material(
        elevation: 3,
        // shape: 10.roundedShape,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: TabBar(
            labelStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.greyUnavailable,
                fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontSize: 15, color: AppColors.greyUnavailable),
            indicatorColor: AppColors.primaryShiny,
            controller: _tabController,
            tabs: [
              Tab(child: 'Editor'.toText()),
              Tab(child: 'View code'.toText()),
            ],
          ),
        ),
      ),
    );
  }
}