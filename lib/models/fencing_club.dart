/// フェンシングクラブのデータモデル
class FencingClub {
  late String Prefecture;
  late String Name;
  late String HomePage;
  late String Address;
  late String Qualification;
  late String Fee;
  late String Date;
  late String Remarks;

  FencingClub(String prefecture, String name, String homePage, String address,
      String qualification, String fee, String date, String remarks) {
    Prefecture = prefecture;
    Name = name;
    HomePage = homePage;
    Address = address;
    Qualification = qualification;
    Fee = fee;
    Date = date;
    Remarks = remarks;
  }
}
