import 'package:active_flutter_delivery_app/custom/lang_text.dart';
import 'package:active_flutter_delivery_app/custom/toast_component.dart';
import 'package:active_flutter_delivery_app/helpers/shimmer_helper.dart';
import 'package:active_flutter_delivery_app/helpers/sortable.dart';
import 'package:active_flutter_delivery_app/my_theme.dart';
import 'package:active_flutter_delivery_app/other_config.dart';
import 'package:active_flutter_delivery_app/repositories/delivery_repository.dart';
import 'package:active_flutter_delivery_app/screens/order_details.dart';
import 'package:active_flutter_delivery_app/screens/single_order_map.dart';
import 'package:active_flutter_delivery_app/ui_sections/drawer.dart';
import 'package:flutter/material.dart';

import 'package:toast/toast.dart';

class OnTheWayDelivery extends StatefulWidget {
  OnTheWayDelivery({
    Key? key,
    this.show_back_button = false,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  bool show_back_button;

  @override
  _OnTheWayDeliveryState createState() => _OnTheWayDeliveryState();
}

class _OnTheWayDeliveryState extends State<OnTheWayDelivery> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();

  List<Sortable> _datewiseSortList = Sortable.getDatewiseSortList();
  List<Sortable> _paymentTypeSortList = Sortable.getPaymentTypeSortList();

  Sortable? _selectedDate;
  Sortable? _selectedPaymentType;

  late List<DropdownMenuItem<Sortable>> _dropdownDatewiseSortItems;
  late List<DropdownMenuItem<Sortable>> _dropdownPaymentTypeSortItems;

  //init

  List<dynamic> _list = [];
  bool _isInitial = true;
  int _page = 1;
  int? _totalData = 0;
  bool _showLoadingContainer = false;

  String _defaultDateKey = '';
  String _defaultPaymentTypeKey = '';
  var _marked_ids = [];

  @override
  void initState() {
    // TODO: implement initState
    init();
    super.initState();

    fetchData();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  init() {
    _dropdownDatewiseSortItems = buildDropdownItems(_datewiseSortList);

    _dropdownPaymentTypeSortItems = buildDropdownItems(_paymentTypeSortList);

    initSortableDefaults();
  }

  initSortableDefaults() {
    for (int x = 0; x < _dropdownDatewiseSortItems.length; x++) {
      if (_dropdownDatewiseSortItems[x].value!.option_key == _defaultDateKey) {
        _selectedDate = _dropdownDatewiseSortItems[x].value;
      }
    }

    for (int x = 0; x < _dropdownPaymentTypeSortItems.length; x++) {
      if (_dropdownPaymentTypeSortItems[x].value!.option_key ==
          _defaultPaymentTypeKey) {
        _selectedPaymentType = _dropdownPaymentTypeSortItems[x].value;
      }
    }

    setState(() {});
  }

  List<DropdownMenuItem<Sortable>> buildDropdownItems(List _paymentStatusList) {
    List<DropdownMenuItem<Sortable>> items = [];
    for (Sortable item in _paymentStatusList as Iterable<Sortable>) {
      items.add(
        DropdownMenuItem(
          value: item,
          child: Text(item.name),
        ),
      );
    }
    return items;
  }

  fetchData() async {
    var listResponse = await DeliveryRepository().getDeliveryListResponse(
        page: _page,
        type: "on_the_way",
        date_range: _selectedDate!.option_key,
        payment_type: _selectedPaymentType!.option_key);
    //print("or:"+orderResponse.toJson().toString());
    _list.addAll(listResponse.orders!);
    _isInitial = false;
    _totalData = listResponse.meta!.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _list.clear();
    _marked_ids.clear();
    _isInitial = true;
    _page = 1;
    _totalData = 0;
    _showLoadingContainer = false;
    setState(() {});
  }

  resetFilterKeys() {
    _defaultDateKey = '';
    _defaultPaymentTypeKey = '';

    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    resetFilterKeys();
    initSortableDefaults();
    fetchData();
  }

  onPop(value) {
    reset();
    resetFilterKeys();
    initSortableDefaults();
    fetchData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  onPressMarkDelivered(order_id) {
    showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              contentPadding: EdgeInsets.only(
                  top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
              content: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  LangText(context)
                      .local!
                      .are_you_sure_to_mark_this_as_delivered,
                  maxLines: 3,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 14),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(
                    LangText(context).local!.close_ucf,
                    style: TextStyle(color: MyTheme.medium_grey),
                  ),
                  onPressed: () {
                    Navigator.pop(alertContext);
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: MyTheme.red,
                  ),
                  child: Text(
                    LangText(context).local!.confirm_ucf,
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(alertContext);
                    onConfirmMarkDelivered(order_id);
                  },
                ),
              ],
            ));
  }

  onConfirmMarkDelivered(order_id) async {
    var deliveryStatusChangeResponse = await DeliveryRepository()
        .getDeliveryStatusChangeResponse(
            status: "delivered", order_id: order_id);

    if (deliveryStatusChangeResponse.result == true) {
      ToastComponent.showDialog(deliveryStatusChangeResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      _marked_ids.add(order_id);
      setState(() {});
    } else {
      ToastComponent.showDialog(deliveryStatusChangeResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => widget.show_back_button,
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: buildAppBar(context),
          key: _scaffoldKey,
          drawer: MainDrawer(),
          body: Stack(
            children: [
              RefreshIndicator(
                color: MyTheme.accent_color,
                backgroundColor: Colors.white,
                onRefresh: _onRefresh,
                displacement: 0,
                child: CustomScrollView(
                  controller: _xcrollController,
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        buildList(),
                        Container(
                          height: 100,
                        )
                      ]),
                    )
                  ],
                ),
              ),
              Align(alignment: Alignment.center, child: buildLoadingContainer())
            ],
          )),
    );
  }

  buildBottomAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Container(
              height: 36,
              width: 36,
              decoration: BoxDecoration(
                color: MyTheme.red,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/human_run.png",
                  color: Colors.white,
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "${LangText(context).local!.on_the_way_ucf} (${_totalData.toString()})",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: MyTheme.red,
                  fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(115.0),
      child: AppBar(
          centerTitle: false,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            new Container(),
          ],
          elevation: 0.0,
          titleSpacing: 0,
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
            child: Column(
              children: [
                Padding(
                  padding: MediaQuery.of(context).viewPadding.top >
                          30 //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                      ? const EdgeInsets.only(top: 36.0)
                      : const EdgeInsets.only(top: 14.0),
                  child: buildTopAppBarContainer(),
                ),
                buildBottomAppBar(context)
              ],
            ),
          )),
    );
  }

  Container buildTopAppBarContainer() {
    return Container(
      child: Row(
        children: [
          widget.show_back_button
              ? Builder(
                  builder: (context) => IconButton(
                      icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
                      onPressed: () {
                        return Navigator.of(context).pop();
                      }),
                )
              : Builder(
                  builder: (context) => GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState!.openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 18.0, horizontal: 12.0),
                      child: Container(
                        child: Image.asset(
                          'assets/hamburger.png',
                          height: 16,
                          //color: MyTheme.dark_grey,
                          color: MyTheme.dark_grey,
                        ),
                      ),
                    ),
                  ),
                ),
          Text(
            LangText(context).local!.pending_delivery_ucf,
            style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
          ),
        ],
      ),
    );
  }

  buildList() {
    if (_isInitial && _list.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildListShimmer(item_count: 5, item_height: 100.0));
    } else if (_list.length > 0) {
      return SingleChildScrollView(
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _list.length,
          scrollDirection: Axis.vertical,
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: buildListItem(index));
          },
        ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text(LangText(context).local!.no_data_is_available));
    } else {
      return Container(); // should never be happening
    }
  }

  buildListItem(int index) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          elevation: 0.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LangText(context).local!.order_code_ucf,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text(
                        _list[index].code,
                        style: TextStyle(
                            color: MyTheme.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      Text(_list[index].date,
                          style: TextStyle(
                              color: MyTheme.font_grey, fontSize: 13)),
                      Spacer(),
                      Text(
                        _list[index].grand_total,
                        style: TextStyle(
                            color: MyTheme.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LangText(context).local!.payment_status_ucf,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            _list[index].payment_type,
                            style: TextStyle(
                                color: MyTheme.font_grey, fontSize: 13),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: buildPaymentStatusCheckContainer(
                                _list[index].payment_status),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        OtherConfig.USE_GOOGLE_MAP
            ? Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, right: 4.0, top: 4.0, bottom: 4.0),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      border:
                          Border.all(color: MyTheme.textfield_grey, width: 1),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(6.0))),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      minimumSize:
                          Size((MediaQuery.of(context).size.width - 36) / 2, 0),
                      //height: 50,
                      backgroundColor: MyTheme.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6.0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Icon(
                            Icons.location_on,
                            size: 20,
                            color: MyTheme.red,
                          ),
                        ),
                        Text(
                          LangText(context).local!.get_direction_ucf,
                          style: TextStyle(
                              color: MyTheme.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (!_list[index].location_available) {
                        ToastComponent.showDialog(
                            LangText(context).local!.location_not_available,
                            context,
                            gravity: Toast.center,
                            duration: Toast.lengthLong);
                        return;
                      }
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SingleOrderMap(
                          order: _list[index],
                          color: MyTheme.red,
                        );
                      })).then((value) {
                        onPop(value);
                      });
                    },
                  ),
                ),
              )
            : Container(),
        Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 4.0, top: 4.0, bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 48,
                decoration: BoxDecoration(
                    border: Border.all(color: MyTheme.textfield_grey, width: 1),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0))),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize:
                        Size((MediaQuery.of(context).size.width - 36) / 2, 0),
                    //height: 50,
                    backgroundColor: MyTheme.white,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6.0))),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.assignment_outlined,
                          size: 14,
                          color: MyTheme.font_grey,
                        ),
                      ),
                      Text(
                        LangText(context).local!.view_details_ucf,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return OrderDetails(
                        id: _list[index].id,
                        show_additional_section: true,
                      );
                    })).then((value) {
                      onPop(value);
                    });
                  },
                ),
              ),
              _marked_ids.contains(_list[index].id)
                  ? Container(
                      height: 48,
                      width: MediaQuery.of(context).size.width / 2 - 16,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6.0))),
                      child: Center(
                        child: Text(
                          LangText(context).local!.delivered_ucf,
                          style: TextStyle(
                              color: MyTheme.font_grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  : Container(
                      height: 48,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: MyTheme.textfield_grey, width: 1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6.0))),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          minimumSize: Size(
                              (MediaQuery.of(context).size.width - 36) / 2, 0),
                          //height: 50,
                          backgroundColor: MyTheme.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6.0))),
                        ),
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: buildCheckContainer()),
                            Text(
                              LangText(context).local!.mark_as_delivered,
                              style: TextStyle(
                                  color: MyTheme.font_grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        onPressed: () {
                          onPressMarkDelivered(_list[index].id);
                        },
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Container buildPaymentStatusCheckContainer(String? payment_status) {
    return Container(
      height: 16,
      width: 16,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: payment_status == "paid" ? Colors.green : Colors.red),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(
            payment_status == "paid" ? Icons.check : Icons.close,
            color: Colors.white,
            size: 10),
      ),
    );
  }

  Container buildCheckContainer() {
    return Container(
      height: 18,
      width: 18,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0), color: MyTheme.lime),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(Icons.check, color: Colors.white, size: 12),
      ),
    );
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _list.length
            ? LangText(context).local!.no_more_items_ucf
            : LangText(context).local!.loading_more_items_ucf),
      ),
    );
  }
}
