import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ongkir/app/modules/home/province_model.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cek Ongkir'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: [
            DropdownSearch<Province>(
              popupProps: PopupProps.modalBottomSheet(
                showSearchBox: true,
                itemBuilder: (context, item, isSelected) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                    child: Text(
                      "${item.province}",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                },
              ),
              itemAsString: (item) => item.province!,
              clearButtonProps: ClearButtonProps(isVisible: true),
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  labelText: "Provinsi Asal",
                  hintText: "Pilih Provinsi Asal",
                  hintStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
              asyncItems: (String filter) async {
                try {
                  var url =
                      Uri.parse('https://api.rajaongkir.com/starter/province');
                  var response = await http.get(url,
                      headers: {'key': 'f1b9f431049ed6a16efcc3a99149c3c8'});

                  var data = jsonDecode(response.body) as Map<String, dynamic>;
                  var statusCode = data['rajaongkir']['status']['code'];

                  if (statusCode != 200) {
                    throw data['rajaongkir']['status']['description'];
                  }

                  var listAllProvince =
                      data['rajaongkir']['results'] as List<dynamic>;

                  var models = Province.fromJsonList(listAllProvince);
                  return models;
                } catch (e) {
                  print(e);
                  return List<Province>.empty();
                }
              },
              onChanged: (Province? data) {
                print(data?.province);
              },
            )
          ],
        ));
  }
}
