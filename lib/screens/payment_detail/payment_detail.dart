import 'package:flutter/material.dart';
import 'package:mphb_app/controller/payment_controller.dart';
import 'package:mphb_app/models/payment.dart';

class PaymentDetailScreen extends StatefulWidget {

	const PaymentDetailScreen({Key? key, required this.payment}) : super(key: key);

	final Payment payment;

	@override
	_PaymentDetailScreenState createState() => _PaymentDetailScreenState( paymentID: this.payment.id );

}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {

	_PaymentDetailScreenState({
		required this.paymentID
	});

	late final PaymentController _paymentController;

	late Future<Payment> _paymentFuture;

	final int paymentID;

	@override
	void initState() {

		_paymentController = new PaymentController();
		_paymentFuture = _paymentController.wpGetPayment( paymentID );

		super.initState();
	}

	@override
	Widget build(BuildContext context) {

		return WillPopScope(
			child: Scaffold(
				appBar: AppBar(
					title: Text( 'Payment #$paymentID' ),
					actions: <Widget>[
						IconButton(
							icon: const Icon(Icons.sync),
							tooltip: 'Refresh',
							onPressed: () {
								setState(() {
									_paymentFuture = _paymentController.wpGetPayment( paymentID );
								});
							},
						),
						FutureBuilder(
							future: _paymentFuture,
							builder: (context, AsyncSnapshot snapshot) {
								if (snapshot.connectionState == ConnectionState.waiting) {
									return new Center(
										child: Padding(
											padding: const EdgeInsets.all(14),
											child: SizedBox(
												child: CircularProgressIndicator(
													color: Colors.black,
													strokeWidth: 2.0,
												),
												height: 20.0,
												width: 20.0,
											),
										),
									);
								} else if (snapshot.hasError) {
									return new Container();
								} else {

									Payment payment = snapshot.data;

									return Container();
									/*return IconButton(
										icon: const Icon(Icons.more_vert),
										tooltip: 'Actions',
										onPressed: () {
											showModalBottomSheet(
												context: context,
												builder: (context) {
													return PaymentDetailActions( payment: payment );
												},
											).then((action) {

												//print('Action: $action');
												if ( action != null ) {
													switch ( action ) {
														case 'delete':
															print('Delete payment!');
															break;
														default:
															setState(() {
																_paymentFuture = _paymentController.wpUpdatePaymentStatus( payment, action );
															});
													}
												}
											});
										},
									);*/
								}
							}
						),
					],
				),
				body: FutureBuilder(
					future: _paymentFuture,
					initialData: widget.payment,
					builder: (context, AsyncSnapshot snapshot) {
						/*if (snapshot.connectionState == ConnectionState.waiting) {
							return new Center(
								child: new CircularProgressIndicator(),
							);
						} else*/ if (snapshot.hasError) {
							return new Text('Error: ${snapshot.error}');
						} else {

							Payment payment = snapshot.data;

							return RefreshIndicator(
								onRefresh: () => Future.sync(
									() => setState(() {
										_paymentFuture = _paymentController.wpGetPayment( paymentID );
									}),
								),
								child: SingleChildScrollView(
									physics: AlwaysScrollableScrollPhysics(),
									child: Container(
										padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
										child: Column(
											children: [
												
											],
										),
									),
								),
							);
						}
					}
				),
			),
			onWillPop: () async {
				Navigator.pop(context, _paymentFuture);
				return false;
			}
		);
	}
}
