class Data {
  int stock;
  String barCode;
  String description;
  double preco;
  int qantidade;

  Data({
    required this.qantidade,
    required this.stock,
    required this.preco,
    required this.barCode,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'barCode': barCode,
      'preco': preco,
      'description': description,
      'quantidade': qantidade
    };
  }

  Data.fromFirestore(Map<String, dynamic> data)
      : barCode = data['barCode'] ?? 1000,
        preco = data['price'],
        description = data['description'],
        stock = data['stock'],
        qantidade = data['quantidade'];
}
