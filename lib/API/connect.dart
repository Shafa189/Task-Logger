// This class provides static constants for API endpoints used in the application.
class ApiConnect {
  // The base URL for the API server.
  static const hostConnect = "https://apiserverrrr.000webhostapp.com";

  // The complete base URL for connecting to the API.
  static const connectApi = "$hostConnect";

  // Endpoint to add a user.
  static const register = "$connectApi/register.php";
  static const login = "$connectApi/login.php";
  static const getact = "$connectApi/getact.php";
  static const update = "$connectApi/updateprof.php";
  static const editusers = "$connectApi/editusers.php";
  static const getuser = "$connectApi/getuser.php";
  static const addact = "$connectApi/addactivity.php";
  static const edit = "$connectApi/editusers.php";
  static const editact = "$connectApi/editact.php";
  static const delete = "$connectApi/delete.php";
}
