import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class OutputSelection extends StatefulWidget {
  final Set<String> selectedOutputs;
  final Function(Set<String>) onSelectionChanged;
  final List<String> availableOutputs;
  
  const OutputSelection({
    Key? key,
    required this.selectedOutputs,
    required this.onSelectionChanged,
    this.availableOutputs = const ['Text', 'Voice', 'Video', 'Music'],
  }) : super(key: key);

  @override
  State<OutputSelection> createState() => _OutputSelectionState();
}

class _OutputSelectionState extends State<OutputSelection> {
  late Set<String> _selectedOutputs;
  
  @override
  void initState() {
    super.initState();
    _selectedOutputs = Set.from(widget.selectedOutputs);
  }
  
  @override
  void didUpdateWidget(OutputSelection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedOutputs != widget.selectedOutputs) {
      setState(() {
        _selectedOutputs = Set.from(widget.selectedOutputs);
      });
    }
  }
  
  void _toggleOutput(String output) {
    setState(() {
      if (_selectedOutputs.contains(output)) {
        _selectedOutputs.remove(output);
      } else {
        _selectedOutputs.add(output);
      }
    });
    widget.onSelectionChanged(_selectedOutputs);
  }
  
  IconData _getOutputIcon(String output) {
    switch (output) {
      case 'Text':
        return Icons.text_fields;
      case 'Voice':
        return Icons.mic;
      case 'Video':
        return Icons.videocam;
      case 'Music':
        return Icons.music_note;
      default:
        return Icons.output;
    }
  }
  
  Color _getOutputColor(String output) {
    switch (output) {
      case 'Text':
        return Colors.blue;
      case 'Voice':
        return Colors.green;
      case 'Video':
        return Colors.purple;
      case 'Music':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите формат вывода',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SizedBox(height: 8),
        Text(
          'Можно выбрать несколько форматов одновременно',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: widget.availableOutputs.map((output) {
            final isSelected = _selectedOutputs.contains(output);
            final color = _getOutputColor(output);
            
            return InkWell(
              onTap: () => _toggleOutput(output),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 16,
                  vertical: isDesktop ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getOutputIcon(output),
                      color: isSelected ? color : Colors.grey[600],
                      size: isDesktop ? 24 : 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      output,
                      style: TextStyle(
                        color: isSelected ? color : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: isDesktop ? 16 : 14,
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: color,
                        size: isDesktop ? 20 : 16,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        
        if (_selectedOutputs.isEmpty) ...[
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Выберите хотя бы один формат вывода',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}