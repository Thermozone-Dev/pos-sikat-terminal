import 'package:flutter/material.dart';

class TotalChange extends StatelessWidget {
  final double totalChange;

  const TotalChange({Key? key, required this.totalChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Change :',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          Text(
            '₱ ${totalChange.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.brown[500],
            ),
          ),
        ],
      ),
    );
  }
}
