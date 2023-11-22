import 'package:buxa/database/person_repository.dart';
import 'package:buxa/database/debt_repository.dart';
import 'package:buxa/data_model/person_data_model.dart';
import 'package:buxa/widgets/error_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:buxa/data_model/debt_data_model.dart';
import 'package:buxa/model/new_person_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewDebtDialogModel {
  Future<int?> insertPersonIfNeeded(String name, BuildContext context) async {
    if (!kIsWeb) {
      final personDbHelper = PersonRepository();
      final existingPerson = await personDbHelper.getPersonByName(name);
      if (existingPerson != null) {
        return existingPerson.id;
      } else {
        final newPerson = PersonDataModel(name: name);
        final newPersonId = await personDbHelper.insertPerson(newPerson);
        return newPersonId;
      }
    } else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final firestore = FirebaseFirestore.instance;
          final userEmail = user.email;

          final existingPerson = await getPersonByNameWeb(name);
          if (existingPerson != null) {
            return existingPerson.id;
          } else {
            final peopleCollectionRef = firestore
                .collection(userEmail!)
                .doc('userData')
                .collection('People');

            try {
              final NewPersonModel _model = NewPersonModel();
              final result = await _model.insertPerson(
                  name, "looool@gmail.com", false, context);

              final newPerson2 = await getPersonByNameWeb(name);
              print("loool: ${newPerson2?.id}");
              return newPerson2?.id;
            } catch (error) {
              print('Hiba történt a Firestore-ba való beszúrás közben: $error');
              return null;
            }

            //return int.tryParse(newPersonDocRef.id);
          }
        }
      } catch (e) {
        print('Hiba történt a személy hozzáadása közben: $e');
        return null;
      }
    }
  }

  Future<void> insertDebt(DebtDataModel newDebt) async {
    if (!kIsWeb) {
      final dbHelper = DebtRepository();
      await dbHelper.insertDebt(newDebt);
    } else {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final firestore = FirebaseFirestore.instance;
          final userEmail = user.email;

          // Adósság hozzáadása a Firestore-ba
          await firestore
              .collection(userEmail!)
              .doc('userData')
              .collection('Debts')
              .add(newDebt.toMap());
        }
      } catch (e) {
        print('Hiba történt az adósság hozzáadása közben: $e');
      }
    }
  }

  Future<List<PersonDataModel>> loadPersons() async {
    if (!kIsWeb) {
      final personDbHelper = PersonRepository();
      final personList = await personDbHelper.getPersonList();
      return personList.whereType<PersonDataModel>().toList();
    } else {
      List<PersonDataModel> peopleList = [];
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final firestore = FirebaseFirestore.instance;
        final userEmail = user.email;

        final peopleCollectionRef = firestore
            .collection(userEmail!)
            .doc('userData')
            .collection('People');

        final peopleQuerySnapshot = await peopleCollectionRef.get();
        if (peopleQuerySnapshot.docs.isNotEmpty) {
          peopleList = peopleQuerySnapshot.docs
              .map((doc) => PersonDataModel.fromMap(doc.data()))
              .toList();
          return peopleList;
        } else {
          //ErrorDialog.show(context, 'Nincsenek adatok a Firestore-ban.');
        }
      } else {
        //ErrorDialog.show(context, 'Nem vagy bejelentkezve.');
      }
    }
    return [];
  }

  Future<PersonDataModel?> getPersonByNameWeb(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firestore = FirebaseFirestore.instance;
      final userEmail = user.email;

      final personQuerySnapshot = await firestore
          .collection(userEmail!)
          .doc('userData')
          .collection('People')
          .where('name', isEqualTo: name)
          .get();

      if (personQuerySnapshot.docs.isNotEmpty) {
        final personDoc = personQuerySnapshot.docs.first;
        return PersonDataModel.fromMap(personDoc.data()!);
      }
    }

    return null;
  }
}
