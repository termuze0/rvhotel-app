class CartItem {
  final int id;
  final String name;
  final double price;
  int quantity;
  final String? image;
  final String? hotelName;
  final int? hotelId; // Add this field

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.hotelName,
    this.hotelId, // Add this
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': image,
        'hotel_name': hotelName,
        'hotel_id': hotelId,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'],
        name: json['name'],
        price: json['price'].toDouble(),
        quantity: json['quantity'],
        image: json['image'],
        hotelName: json['hotel_name'],
        hotelId: json['hotel_id'],
      );
}
