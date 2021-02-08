import 'dart:convert';

int generateSimpleHash(String str) {
  int length = str.length;
  int i = 0;
  String s = '';
  while (i < length) {
    s = s + getPlaceInAlphabet(str[i]).toString() + '0';
    i++;
  }
  if (s.length < 18) {
    s = s.substring(0, s.length);
  } else {
    s = s.substring(0, 18);
  }

  print('hash =' + int.parse(s).toString());
  return int.parse(s);
}

int getPlaceInAlphabet(String str) {
  if (str == 'a') {
    return 1;
  }
  if (str == 'b') {
    return 2;
  }
  if (str == 'c') {
    return 3;
  }
  if (str == 'd') {
    return 4;
  }
  if (str == 'e') {
    return 5;
  }
  if (str == 'f') {
    return 6;
  }
  if (str == 'g') {
    return 7;
  }
  if (str == 'h') {
    return 8;
  }
  if (str == 'i') {
    return 9;
  }
  if (str == 'j') {
    return 10;
  }
  if (str == 'k') {
    return 11;
  }
  if (str == 'l') {
    return 12;
  }
  if (str == 'm') {
    return 13;
  }
  if (str == 'n') {
    return 14;
  }
  if (str == 'o') {
    return 15;
  }
  if (str == 'p') {
    return 16;
  }
  if (str == 'q') {
    return 17;
  }
  if (str == 'r') {
    return 18;
  }
  if (str == 's') {
    return 19;
  }
  if (str == 't') {
    return 20;
  }
  if (str == 'u') {
    return 21;
  }
  if (str == 'v') {
    return 22;
  }
  if (str == 'w') {
    return 23;
  }
  if (str == 'x') {
    return 24;
  }
  if (str == 'y') {
    return 25;
  }
  if (str == 'z') {
    return 26;
  }
  if (str == '1') {
    return 27;
  }
  if (str == '2') {
    return 28;
  }
  if (str == '3') {
    return 29;
  }
  if (str == '4') {
    return 30;
  }
  if (str == '5') {
    return 31;
  }
  if (str == '6') {
    return 32;
  }
  if (str == '7') {
    return 33;
  }
  if (str == '8') {
    return 34;
  }
  if (str == '9') {
    return 35;
  }
  return 36;
}
