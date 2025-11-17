// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Discurso {
  int? id;
  String titulo;
  String descricao;
  String dataCriacao;
  String? categoria;

  Discurso({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.dataCriacao,
    this.categoria,
  });

  // Converter Map para Discurso
  factory Discurso.fromMap(Map<String, dynamic> map) {
    return Discurso(
      id: map['id'] != null ? map['id'] as int : null,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      dataCriacao: map['data_criacao'] as String,
      categoria: map['categoria'] != null ? map['categoria'] as String : null,
    );
  }

  // Converter Discurso para Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data_criacao': dataCriacao,
      'categoria': categoria,
    };
  }

  Discurso copyWith({
    int? id,
    String? titulo,
    String? descricao,
    String? dataCriacao,
    String? categoria,
  }) {
    return Discurso(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      categoria: categoria ?? this.categoria,
    );
  }

  String toJson() => json.encode(toMap());

  factory Discurso.fromJson(String source) =>
      Discurso.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Discurso(id: $id, titulo: $titulo, descricao: $descricao, dataCriacao: $dataCriacao, categoria: $categoria)';
  }

  @override
  bool operator ==(covariant Discurso other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.titulo == titulo &&
        other.descricao == descricao &&
        other.dataCriacao == dataCriacao &&
        other.categoria == categoria;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        titulo.hashCode ^
        descricao.hashCode ^
        dataCriacao.hashCode ^
        categoria.hashCode;
  }
}
