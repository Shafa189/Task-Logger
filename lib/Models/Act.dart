class NoteData {
  String? id; // Unique identifier for the note.
  String? userId; // User ID associated with the note.
  String? title; // Title of the note.
  String? image; // Filename of the image associated with the note.
  String? description; // Description or content of the note.

  // Constructor for creating a NoteData object.
  NoteData({
    this.id,
    this.userId,
    this.title,
    this.image,
    this.description,
  });

  // Factory method to create a NoteData object from a JSON map.
  NoteData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
  }

  // Method to convert the NoteData object to a JSON map for serialization.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['image'] = this.image;
    data['description'] = this.description;
    return data;
  }
}
