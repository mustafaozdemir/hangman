import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hangman/components/alphabet.dart';
import 'package:hangman/services/score_service.dart';
import '../components/colors.dart';
import '../components/figure_image.dart';
import '../language/langlist.dart';
import '../language/language.dart';
import '../models/score_model.dart';
import '../components/word.dart';
import '../services/words_service.dart';

class PlayGamePage extends StatefulWidget {
  final WordService hangmanWords = WordService();
  final WordService? hangmanObject;
  PlayGamePage({Key? key, @required this.hangmanObject}) : super(key: key);

  @override
  State<PlayGamePage> createState() => _PlayGamePageState();
}

class _PlayGamePageState extends State<PlayGamePage> {
  Language? selectedLang;
  var userService = ScoreService();
  String alphabets = "";
  List<String> alphabet = [];
  int tries = 6;
  List<String> selectedChar = [];
  String wordSelected = '';
  bool isGameOver = false;
  bool isWin = false;

  @override
  void initState() {
    newGame();
    super.initState();
  }

  void newGame() {
    setState(() {
      if (!isGameOver) {
        tries = 6;
        selectedChar = [];
        wordSelected = '';
        isGameOver = false;
        isWin = false;
        wordSelected = widget.hangmanObject!.getWord()!.toUpperCase();
        //print(wordSelected);
      }
    });
  }

  void writeScore() async {
    var score = ScoreModel();
    score.date = DateTime.now().toString();
    score.score = tries;
    userService.saveScore(score);
  }

  @override
  Widget build(BuildContext context) {
    selectedLang = languageList.singleWhere((e) => e.locale == context.locale);
    if (selectedLang!.langName == 'English - US') {
      alphabets = Alphabet().alphabet_en;
    } else if (selectedLang!.langName == 'Türkçe - TR') {
      alphabets = Alphabet().alphabet_tr;
    }
    alphabet = alphabets.split('');
    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      appBar: AppBar(
        title: const Text("HangmaN"),
      ),
      body: View_GamePage(context, alphabet),
    );
  }

  Column View_GamePage(BuildContext context, List<String> alphabets) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            children: [
              figureImage(tries < 7, "images/hang.png"),
              figureImage(tries < 6, "images/head.png"),
              figureImage(tries < 5, "images/body.png"),
              figureImage(tries < 4, "images/ra.png"),
              figureImage(tries < 3, "images/la.png"),
              figureImage(tries < 2, "images/rl.png"),
              figureImage(tries < 1, "images/ll.png"),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 50),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: wordSelected
                  .split('')
                  .map((e) => word(e.toUpperCase(), !selectedChar.contains(e.toUpperCase())))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 300.0,
          child: isGameOver ? View_Score(context) : View_Alphabet(alphabet),
        )
      ],
    );
  }

  Column View_Score(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        isWin
            ? Text(
                'you_win'.tr(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Column(
                children: [
                  Text('${'hidden_word'.tr()} : $wordSelected',
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  Text(
                    'you_lost'.tr(),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (BuildContext context) => super.widget));
          },
          child: Text(
            'new_game'.tr(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ButtonStyle(
            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'home'.tr(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  GridView View_Alphabet(List<String> alphabets) {
    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 7.0,
      crossAxisSpacing: 7.0,
      padding: const EdgeInsets.all(10.0),
      children: alphabets.map((e) {
        return RawMaterialButton(
          onPressed: selectedChar.contains(e)
              ? null
              : () {
                  if (!isGameOver) {
                    setState(() {
                      selectedChar.add(e);
                      var comparing = wordSelected
                          .split('')
                          .toList()
                          .where((element) => selectedChar.contains(element));
                      if (!wordSelected.split('').contains(e.toUpperCase())) {
                        tries--;
                        if (tries < 1) {
                          isGameOver = true;
                          isWin = false;
                          writeScore();
                        }
                      } else if (comparing.length == wordSelected.replaceAll(' ', '').length) {
                        isGameOver = true;
                        isWin = true;
                        writeScore();
                      }
                    });
                  }
                },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
          fillColor: selectedChar.contains(e) ? Colors.black87 : Colors.blue,
          child: Text(
            e,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }
}
