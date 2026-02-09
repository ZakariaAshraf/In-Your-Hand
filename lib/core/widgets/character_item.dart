import 'package:flutter/material.dart';
import 'package:in_your_hand/core/utils/screen_util.dart';

class CharacterItem extends StatelessWidget {
final CharacterModel character;
final double? width;
final double? height;
final bool isSelected;
final bool showCharName;

  final void Function()? onTap;

  const CharacterItem({
    super.key,
    this.onTap, required this.character, required this.isSelected, this.width, this.height, this.showCharName=true,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    return Card(
      elevation: isSelected==true ? 4 : 0 ,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10),
          width:width ?? 400,
          height: height ??400,
          decoration: BoxDecoration(
            border:isSelected==true ? BoxBorder.all(color: Colors.red) : null,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  fit: BoxFit.contain,
                  character.imagePath,
                ),
              ),
              SizedBox(height: 10.h(context)),
              if (showCharName) ...[
                SizedBox(height: 5.h(context)),
                Text(
                  character.imageName,
                  textAlign: TextAlign.center,
                  style: theme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp(context),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterModel{
  final String id;
  final String imagePath;
  final String imageName;
  CharacterModel( {required this.imagePath, required this.imageName,
    required this.id,
  });
}
