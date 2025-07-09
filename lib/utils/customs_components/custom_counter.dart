import 'package:flutter/material.dart';

class QuantityCounter extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  const QuantityCounter({
    super.key,
    this.initialQuantity = 1,
    this.maxQuantity = 100,
    required this.onChanged,
  })  : assert(initialQuantity >= 0,
            'Initial quantity cannot be negative'), // Garante que a quantidade inicial não seja negativa
        assert(maxQuantity >= 0,
            'Max quantity cannot be negative'), // Garante que a quantidade máxima não seja negativa
        assert(initialQuantity <= maxQuantity,
            'Initial quantity cannot exceed max quantity'); // Garante que a quantidade inicial não seja maior que a máxima

  @override
  State<QuantityCounter> createState() => _QuantityCounterState();
}

class _QuantityCounterState extends State<QuantityCounter> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity.clamp(0, widget.maxQuantity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_currentQuantity);
    });
  }

  void _increment() {
    setState(() {
      if (_currentQuantity < widget.maxQuantity) {
        _currentQuantity++;
        widget.onChanged(_currentQuantity);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (_currentQuantity > 1) {
        _currentQuantity--;
        widget.onChanged(_currentQuantity);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle),
          onPressed: _currentQuantity > 0 ? _decrement : null,
          color: _currentQuantity > 0 ? Colors.red : Colors.grey,
        ),
        Text(
          '$_currentQuantity',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle),
          onPressed: _currentQuantity < widget.maxQuantity ? _increment : null,
          color: _currentQuantity < widget.maxQuantity
              ? Colors.green
              : Colors.grey,
        ),
      ],
    );
  }
}
