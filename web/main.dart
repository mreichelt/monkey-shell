import 'dart:html';
import 'package:monkey_lang/ast/ast.dart';
import 'package:monkey_lang/evaluator/evaluator.dart';
import 'package:monkey_lang/lexer/lexer.dart';
import 'package:monkey_lang/object/environment.dart';
import 'package:monkey_lang/object/object.dart';
import 'package:monkey_lang/parser/parser.dart';

void main() {
  Environment env = new Environment.freshEnvironment();
  String history = 'Hello! This is the Monkey programming language!\n'
      'Feel free to type in commands\n';
  String input = '';

  InputElement inbox = document.getElementById('inbox');
  TextAreaElement outbox = document.getElementById('outbox');

  Function refreshOutbox = () {
    outbox.value = '$history>> $input';
    outbox.scrollTop = outbox.scrollHeight;
  };

  inbox.onKeyUp.forEach((KeyboardEvent event) {
    input = inbox.value;
    if (event.keyCode == KeyCode.ENTER) {
      String evaluated = evaluate(input, env);
      bool nothing = evaluated == null || evaluated == '';
      history += '>> $input\n$evaluated${nothing ? '' : '\n'}';
      inbox.value = input = '';
    }
    refreshOutbox();
  });

  refreshOutbox();
}

String evaluate(String input, Environment env) {
  Parser parser = new Parser(new Lexer(input));
  Program program = parser.parseProgram();
  try {
    MonkeyObject evaluated = eval(program, env);
    if (evaluated != null) {
      return evaluated.inspect();
    }
  } catch (e) {
    return e.toString();
  }
  return '';
}

