import 'package:flutter/material.dart';
import 'package:buxa/data_model/person_data_model.dart';
import 'package:buxa/database/person_repository.dart';
import 'package:buxa/widgets/person_list_item.dart';
import 'package:buxa/data_model/custom_button_data_model.dart';
import 'package:buxa/widgets/desk.dart';
import 'package:buxa/widgets/new_person_dialog.dart';
import 'package:buxa/model/person_model.dart';

class PersonPageViewModel {
  final PersonModel _model = PersonModel();

  late Future<List<PersonDataModel>> peopleFuture;

  PersonPageViewModel(BuildContext context) {
    peopleFuture = _model.loadPeople(context);
  }

  Future<void> refreshPeople(BuildContext context) async {
    await _model.refreshPeople(context);
  }

  Future<void> loadPeople(BuildContext context) async {
    peopleFuture = _model.loadPeople(context);
  }
}
