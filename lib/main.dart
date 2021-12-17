import 'package:chinese_dictionary/dict/hanzi.dart';
import 'package:chinese_dictionary/dict/cantonese_orthography.dart';
import 'package:chinese_dictionary/dict/mandarin_orthography.dart';
import 'package:chinese_dictionary/dict/middle_chinese_orthography.dart';
import 'package:chinese_dictionary/dict/minnan_orthography.dart';
import 'package:chinese_dictionary/dict/shanghainese_orthography.dart';
import 'package:chinese_dictionary/util/db_helper.dart';
import 'package:chinese_dictionary/util/shared_preferences_util.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _init();
  runApp(const App());
}

Future<void> _init() async {
  await Hanzi.instance.init();
  await MandarinOrthography.instance.init();
  await CantoneseOrthography.instance.init();
  await MiddleChineseOrthography.instance.init();
  await MinnanOrthography.instance.init();
  await ShanghaineseOrthography.instance.init();

  await SharedPreferencesUtil.init();
  await DbHelper.instance.init();
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
