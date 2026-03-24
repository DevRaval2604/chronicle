// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      title: fields[0] as String,
      abstract: fields[1] as String,
      byline: fields[2] as String,
      publishedDate: fields[3] as String,
      url: fields[4] as String,
      imageUrl: fields[5] as String,
      section: fields[6] as String,
      subsection: fields[7] as String,
      caption: fields[8] as String,
      geoFacet: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.abstract)
      ..writeByte(2)
      ..write(obj.byline)
      ..writeByte(3)
      ..write(obj.publishedDate)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.section)
      ..writeByte(7)
      ..write(obj.subsection)
      ..writeByte(8)
      ..write(obj.caption)
      ..writeByte(9)
      ..write(obj.geoFacet);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
