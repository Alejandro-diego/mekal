class Data {
  int stock;
  int barCode;
  String description;
  double preco;
  int qantidade;
  int codigoDeProduto;

  Data({
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
      'produto' : codigoDeProduto
    };
  }

  Data.fromFirestore(Map<String, dynamic> data)
      : barCode = data['barCode'] ?? 1000,
        preco = data['price'],
        description = data['description'],
        stock = data['stock'],
        qantidade = data['quantidade'],
        codigoDeProduto = data['produto'];
}
