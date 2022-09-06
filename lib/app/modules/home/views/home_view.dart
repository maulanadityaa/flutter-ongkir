import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ongkir/app/modules/home/city_model.dart';
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
            DropdownProvince(asal: "asal"),
            Obx(() => controller.hiddenCity.isTrue
                ? SizedBox()
                : DropdownCity(
                    provId: controller.provId.value,
                    asal: "asal",
                  )),
            DropdownProvince(asal: "tujuan"),
            Obx(() => controller.hiddenCity.isTrue
                ? SizedBox()
                : DropdownCity(
                    provId: controller.provId.value,
                    asal: "tujuan",
                  )),
          ],
        ));
  }
}

class DropdownProvince extends GetView<HomeController> {
  const DropdownProvince({
    Key? key,
    required this.asal,
  }) : super(key: key);

  final String asal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: DropdownSearch<Province>(
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            itemBuilder: (context, item, isSelected) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Text(
                  "${item.province}",
                  style: TextStyle(fontSize: 18),
                ),
              );
            },
          ),
          itemAsString: (item) => item.province!,
          clearButtonProps: ClearButtonProps(isVisible: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: asal == 'asal'
                  ? 'Pilih Provinsi Asal'
                  : 'Pilih Provinsi Tujuan',
              hintText: asal == 'asal'
                  ? 'Pilih Provinsi Asal'
                  : 'Pilih Provinsi Tujuan',
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
            if (data != null) {
              if (asal == 'asal') {
                controller.hiddenCity.value = false;
                controller.provId.value = int.parse(data.provinceId!);
              } else {
                controller.hiddenCity.value = false;
                controller.provId.value = int.parse(data.provinceId!);
              }
              print(data.province);
            } else {
              controller.hiddenCity.value = true;
              controller.provId.value = 0;
              print('Tidak Memilih Provinsi');
            }
          },
        ),
      ),
    );
  }
}

class DropdownCity extends StatelessWidget {
  const DropdownCity({
    Key? key,
    required this.provId,
    required this.asal,
  }) : super(key: key);

  final int provId;
  final String asal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: DropdownSearch<City>(
          popupProps: PopupProps.modalBottomSheet(
            showSearchBox: true,
            itemBuilder: (context, item, isSelected) {
              return Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Text(
                  "${item.type} ${item.cityName}",
                  style: TextStyle(fontSize: 18),
                ),
              );
            },
          ),
          itemAsString: (item) => item.cityName!,
          clearButtonProps: ClearButtonProps(isVisible: true),
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              labelText: asal == "asal"
                  ? "Kota/Kabupaten Asal"
                  : "Kota/Kabupaten Tujuan",
              hintText: asal == "asal"
                  ? "Pilih Kota/Kabupaten Asal"
                  : "Pilih Kota/Kabupaten Tujuan",
              hintStyle: const TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
          asyncItems: (String filter) async {
            try {
              var url = Uri.parse(
                  'https://api.rajaongkir.com/starter/city?province=$provId');
              var response = await http.get(url,
                  headers: {'key': 'f1b9f431049ed6a16efcc3a99149c3c8'});

              var data = jsonDecode(response.body) as Map<String, dynamic>;
              var statusCode = data['rajaongkir']['status']['code'];

              if (statusCode != 200) {
                throw data['rajaongkir']['status']['description'];
              }

              var listAllCity = data['rajaongkir']['results'] as List<dynamic>;

              var models = City.fromJsonList(listAllCity);
              return models;
            } catch (e) {
              print(e);
              return List<City>.empty();
            }
          },
          onChanged: (City? data) {
            if (data != null) {
              print('${data.type} ${data.cityName}');
            } else {
              print('Tidak Memilih Kota/Kabupaten');
            }
          },
        ),
      ),
    );
  }
}
