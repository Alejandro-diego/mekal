class Data {
  int stock;
  String barCode;
  String description;
  double preco;
  int qantidade;
  String codigoDeProduto;
  double precoUnitario;

  Data({
    required this.precoUnitario,
    required this.codigoDeProduto,
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
      'quantidade': qantidade,
      'produto': codigoDeProduto,
      'precoUnitario' : precoUnitario
    };
  }

  Data.fromFirestore(Map<String, dynamic> data)
      : barCode = data['barCode'] ?? 1000,
      precoUnitario = data['precoUnitario'],
        preco = data['price'],
        description = data['description'],
        stock = data['stock'],
        qantidade = data['quantidade'],
        codigoDeProduto = data['produto'];
}
