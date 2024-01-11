class UserData {
  String? id; // Unique identifier for the user.
  String? image; // Filename of the user's photo.
  String? username; // Username of the user.
  String? password; // Password of the user.
  String? email; // Email address of the user.
  String? address; // Address of the user.

  // Constructor for creating a UserData object.
  UserData({
    this.id,
    this.image,
    this.username,
    this.password,
    this.email,
    this.address,
  });

  // Factory method to create a UserData object from a JSON map.
  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    address = json['address'];
  }

  // Method to convert the UserData object to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['username'] = this.username;
    data['password'] = this.password;
    data['email'] = this.email;
    data['address'] = this.address;
    return data;
  }
}
