import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_currency_api/currencies.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  Dio? dio;
  List<String>? currencies;
  late String selectedCurrency;
  bool isLoading = false;
  bool isCurrencyLoading = false;
  Currency? currentCurrency;

  void initState() {
    super.initState();
    BaseOptions options = BaseOptions();
    options.baseUrl = 'https://api.frankfurter.app/';
    dio = new Dio(options);
    currencies = [];
    getCurrencies();
  }

  Future<void> getCurrency(String code) async {
    setState(() {
      isCurrencyLoading = true;
    });
    final response = await dio?.get("latest?from=$code");
    if (response?.statusCode == 200) {
      currentCurrency = Currency.fromJson(response?.data);
    }
    setState(() {
      isCurrencyLoading = false;
    });
  }

  Future<List<String>?> getCurrencies() async {
    setState(() {
      isLoading = true;
    });
    final response = await dio?.get("currencies");
    if (response?.statusCode == 200) {
      (response?.data as Map).forEach((key, value) {
        currencies?.add(key);
      });
    }
    setState(() {
      isLoading = false;
    });
    selectedCurrency = currencies![0];
    return currencies;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(title: Text("Kur API'si")),
      body: Container(
        alignment: Alignment.topCenter,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text("Kurlar: "),
              isLoading
                  ? CircularProgressIndicator()
                  : DropdownButton<String>(
                      value: selectedCurrency,
                      onChanged: (value) async {
                        setState(() {
                          selectedCurrency = value!;
                        });
                        await getCurrency(value!);
                      },
                      items: currencies
                          ?.map((value) => DropdownMenuItem(
                              value: value, child: Text(value)))
                          .toList()),
              SizedBox(height: 50),
              _buildItems,
            ],
          ),
        ),
      ),
    ));
  }

  Widget get _buildItems => currentCurrency != null
      ? isCurrencyLoading
          ? CircularProgressIndicator()
          : Column(
              children: [
                Text('Kur: ${currentCurrency?.base} '),
                Text(
                    "Tarih : ${currentCurrency?.date.day}/${currentCurrency?.date.month}/${currentCurrency?.date.year}"),
                ListView.separated(
                  separatorBuilder: (_, ind) => Divider(),
                  padding: EdgeInsets.all(10),
                  controller: ScrollController(),
                  shrinkWrap: true,
                  itemCount: currentCurrency!.rates.entries.length,
                  itemBuilder: (_, index) => ListTile(
                    trailing: Text(currentCurrency!.rates.entries
                        .toList()[index]
                        .value
                        .toString()),
                    leading: Text(
                        currentCurrency!.rates.entries.toList()[index].key),
                  ),
                )
              ],
            )
      : Container();
}
