// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'IME';

  @override
  String get booksTitle => 'Sổ';

  @override
  String get noBooksTitle => 'Chưa có sổ nào';

  @override
  String get noBooksBody =>
      'Tạo một sổ cho mỗi thứ bạn quản lý: một nhà trọ, một tiệm bán, một chiếc xe cho thuê.';

  @override
  String get createBook => 'Tạo sổ mới';

  @override
  String get editBook => 'Sửa sổ';

  @override
  String get bookName => 'Tên sổ';

  @override
  String get bookNameHint => 'Nhà trọ Q7';

  @override
  String get bookTemplate => 'Mẫu sổ';

  @override
  String get templateRental => 'Cho thuê';

  @override
  String get templateRentalDesc =>
      'Phòng, nhà, xe có hợp đồng và phiếu thu theo kỳ';

  @override
  String get templateTrading => 'Buôn bán';

  @override
  String get templateTradingDesc =>
      'Thu chi theo danh mục, xem lời lỗ theo tháng';

  @override
  String get templateBlank => 'Sổ trống';

  @override
  String get templateBlankDesc => 'Tự thiết lập từ đầu';

  @override
  String get templateLocked =>
      'Không đổi được mẫu sổ và tiền tệ sau khi đã tạo sổ.';

  @override
  String get currency => 'Tiền tệ';

  @override
  String get note => 'Ghi chú';

  @override
  String get save => 'Lưu';

  @override
  String get delete => 'Xóa';

  @override
  String get cancel => 'Hủy';

  @override
  String get fieldRequired => 'Không được để trống';

  @override
  String get invalidNumber => 'Nhập số hợp lệ';

  @override
  String get deleteBookTitle => 'Xóa sổ này?';

  @override
  String get deleteBookBody => 'Sổ và mọi thứ bên trong sẽ bị xóa.';

  @override
  String get deleteItemTitle => 'Xóa mục này?';

  @override
  String get deleteItemBody => 'Mục này sẽ bị xóa khỏi sổ.';

  @override
  String get itemsRental => 'Tài sản';

  @override
  String get itemsTrading => 'Sản phẩm';

  @override
  String get itemsBlank => 'Đối tượng';

  @override
  String get addItem => 'Thêm';

  @override
  String get editItem => 'Sửa';

  @override
  String get noItems => 'Chưa có gì. Bấm Thêm để tạo cái đầu tiên.';

  @override
  String get itemName => 'Tên';

  @override
  String get itemNameHint => 'Phòng 101';

  @override
  String get itemKind => 'Loại';

  @override
  String get kindRoom => 'Phòng';

  @override
  String get kindHouse => 'Nhà';

  @override
  String get kindVehicle => 'Xe';

  @override
  String get kindProduct => 'Sản phẩm';

  @override
  String get kindOther => 'Khác';

  @override
  String get area => 'Diện tích (m²)';

  @override
  String get defaultPrice => 'Giá mặc định';

  @override
  String get filterAll => 'Tất cả';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mục',
    );
    return '$_temp0';
  }

  @override
  String errorLoading(String message) {
    return 'Có lỗi xảy ra: $message';
  }

  @override
  String get catRent => 'Tiền thuê';

  @override
  String get catElectricity => 'Điện';

  @override
  String get catWater => 'Nước';

  @override
  String get catInternet => 'Internet';

  @override
  String get catRepairs => 'Sửa chữa';

  @override
  String get catSales => 'Bán hàng';

  @override
  String get catIngredients => 'Nguyên liệu';

  @override
  String get catPackaging => 'Bao bì';

  @override
  String get catPremises => 'Mặt bằng';

  @override
  String get catWages => 'Lương';

  @override
  String get catOtherIncome => 'Thu khác';

  @override
  String get catOtherExpense => 'Chi khác';

  @override
  String get navOverview => 'Tổng quan';

  @override
  String get navBooks => 'Sổ';

  @override
  String monthTitle(int month, int year) {
    return 'Tháng $month/$year';
  }

  @override
  String get statIncome => 'Đã thu';

  @override
  String get statExpense => 'Đã chi';

  @override
  String get statProfit => 'Lời';

  @override
  String get statLoss => 'Lỗ';

  @override
  String get toHandleTitle => 'Cần xử lý';

  @override
  String get toHandleEmpty =>
      'Chưa có khoản nào cần thu hay cần trả. Các khoản sẽ hiện ở đây khi bạn tạo hợp đồng hoặc khoản lặp lại.';

  @override
  String get booksSection => 'Các sổ';

  @override
  String get dueReceivable => 'Phải thu';

  @override
  String get duePayable => 'Phải trả';

  @override
  String badgeOverdue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Quá hạn $days ngày',
    );
    return '$_temp0';
  }

  @override
  String get badgeToday => 'Hôm nay';

  @override
  String badgePromised(String date) {
    return 'Hẹn trả $date';
  }

  @override
  String badgeDue(String date) {
    return 'Hạn $date';
  }
}
