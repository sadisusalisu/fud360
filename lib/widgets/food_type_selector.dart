import 'package:flutter/material.dart';
import 'package:fud360/models/donation.dart';
import 'package:fud360/theme/app_theme.dart';

class FoodTypeSelector extends StatelessWidget {
  final FoodType selectedType;
  final Function(FoodType) onTypeSelected;
  
  const FoodTypeSelector({
    Key? key,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildTypeCard(FoodType.cooked, 'Cooked Food', Icons.restaurant_outlined),
        _buildTypeCard(FoodType.raw, 'Raw Ingredients', Icons.egg_outlined),
        _buildTypeCard(FoodType.packaged, 'Packaged Food', Icons.inventory_2_outlined),
        _buildTypeCard(FoodType.baked, 'Baked Goods', Icons.bakery_dining_outlined),
        _buildTypeCard(FoodType.fruits, 'Fruits & Vegetables', Icons.eco_outlined),
        _buildTypeCard(FoodType.other, 'Other', Icons.more_horiz_outlined),
      ],
    );
  }
  
  Widget _buildTypeCard(FoodType type, String label, IconData icon) {
    final isSelected = selectedType == type;
    
    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
