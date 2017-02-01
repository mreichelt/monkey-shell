import 'dart:html';

import 'package:angular2/core.dart';
import 'package:monkey_lang/ast/ast.dart';
import 'package:monkey_lang/evaluator/evaluator.dart';
import 'package:monkey_lang/lexer/lexer.dart';
import 'package:monkey_lang/object/environment.dart';
import 'package:monkey_lang/object/object.dart';
import 'package:monkey_lang/parser/parser.dart';

@Directive(selector: '[autoScroll]')
class AutoScrollDirective implements AfterViewChecked {
  TextAreaElement textArea;

  AutoScrollDirective(ElementRef elRef) {
    this.textArea = elRef.nativeElement;
  }

  @override
  ngAfterViewChecked() {
    textArea.scrollTop = textArea.scrollHeight;
  }
}

@Component(
    selector: 'monkey-shell',
    templateUrl: 'monkey-shell.html',
    directives: const [AutoScrollDirective])
class AppComponent {

  Environment env = new Environment.freshEnvironment();
  String history = 'Hello! This is the Monkey programming language!\n'
      'Feel free to type in commands\n';
  String output = '';
  String input = '';

  void onKey(KeyboardEvent event) {
    InputElement inputElement = event.target as InputElement;
    input = inputElement.value;
    if (event.keyCode == KeyCode.ENTER) {
      String evaluated = evaluate(input);
      bool nothing = evaluated == null || evaluated == '';
      history += '>> $input\n$evaluated${nothing ? '' : '\n'}';
      inputElement.value = input = '';
    }
  }

  String evaluate(String input) {
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

}
