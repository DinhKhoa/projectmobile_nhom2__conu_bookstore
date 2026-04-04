class Book {
  final String id;
  final String title;
  final String author;
  final double price;
  final int stock;
  final String? imageUrl;
  final String categoryId;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.categoryId,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      imageUrl: json['imageUrl'] as String?,
      categoryId: json['categoryId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'price': price,
      'stock': stock,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    };
  }
}
