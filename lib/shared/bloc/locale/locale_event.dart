import 'package:flutter/material.dart';

abstract class LocaleEvent {}

class LocaleChanged extends LocaleEvent {
  final Locale locale;
  LocaleChanged(this.locale);
}