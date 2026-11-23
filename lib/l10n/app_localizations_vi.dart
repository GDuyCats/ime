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

  @override
  String get bookSettings => 'Cài đặt sổ';

  @override
  String get rentTimingLabel => 'Thu tiền phòng';

  @override
  String get rentPostpaid => 'Trả sau';

  @override
  String get rentPostpaidDesc => 'Khách ở trước, hết kỳ mới đóng tiền.';

  @override
  String get rentPrepaid => 'Trả trước';

  @override
  String get rentPrepaidDesc => 'Khách đóng tiền ngay đầu mỗi kỳ.';

  @override
  String get depositMonthsLabel => 'Tiền cọc mặc định (số tháng tiền phòng)';

  @override
  String get noticeDaysLabel => 'Số ngày phải báo trước khi trả phòng';

  @override
  String get defaultChargesTitle => 'Khoản phụ mặc định';

  @override
  String get defaultChargesHint =>
      'Hợp đồng mới sẽ tự lấy các khoản này, từng phòng vẫn sửa riêng được.';

  @override
  String get noCharges => 'Chưa có khoản phụ nào.';

  @override
  String get addCharge => 'Thêm khoản';

  @override
  String get editCharge => 'Sửa khoản';

  @override
  String get chargeName => 'Tên khoản';

  @override
  String get chargeNameHint => 'Điện';

  @override
  String get calcType => 'Cách tính';

  @override
  String get calcMeter => 'Theo chỉ số';

  @override
  String get calcPerPerson => 'Theo đầu người';

  @override
  String get calcFixed => 'Cố định';

  @override
  String get calcManual => 'Nhập tay mỗi kỳ';

  @override
  String get calcManualShort => 'Nhập mỗi kỳ';

  @override
  String get priceMeter => 'Giá mỗi số';

  @override
  String get pricePerPerson => 'Giá mỗi người';

  @override
  String get priceFixed => 'Số tiền mỗi kỳ';

  @override
  String unitMeter(String price) {
    return '$price/số';
  }

  @override
  String unitPerPerson(String price) {
    return '$price/người';
  }

  @override
  String unitFixed(String price) {
    return '$price/kỳ';
  }

  @override
  String get meterStart => 'Số đầu kỳ';

  @override
  String meterReadingValue(String reading) {
    return 'Số đầu $reading';
  }

  @override
  String get removeCharge => 'Bỏ khoản này';

  @override
  String get mustBeWholeNumber => 'Nhập số nguyên';

  @override
  String get currentContract => 'Hợp đồng';

  @override
  String get roomVacant => 'Đang trống';

  @override
  String get roomVacantBody => 'Hiện chưa có ai thuê.';

  @override
  String get rentOut => 'Cho thuê';

  @override
  String get editContract => 'Sửa hợp đồng';

  @override
  String get tenant => 'Người thuê';

  @override
  String get rentAmount => 'Giá thuê';

  @override
  String get cycle => 'Chu kỳ thu';

  @override
  String get cycleDay => 'Theo ngày';

  @override
  String get cycleWeek => 'Theo tuần';

  @override
  String get cycleMonth => 'Theo tháng';

  @override
  String rentPerDay(String amount) {
    return '$amount/ngày';
  }

  @override
  String rentPerWeek(String amount) {
    return '$amount/tuần';
  }

  @override
  String rentPerMonth(String amount) {
    return '$amount/tháng';
  }

  @override
  String get moveInDate => 'Ngày vào';

  @override
  String get nextDue => 'Kỳ thu tới';

  @override
  String firstDueInfo(String date) {
    return 'Kỳ thu đầu tiên: $date';
  }

  @override
  String get occupants => 'Số người ở';

  @override
  String get deposit => 'Tiền cọc';

  @override
  String get depositHeld => 'đang giữ';

  @override
  String get depositNone => 'Không có cọc';

  @override
  String get extraCharges => 'Khoản phụ';

  @override
  String get contractLocked =>
      'Không đổi được ngày vào và chu kỳ thu sau khi đã tạo hợp đồng.';

  @override
  String get tenantExisting => 'Người có sẵn';

  @override
  String get tenantNew => 'Người mới';

  @override
  String get chooseTenant => 'Chọn người thuê';

  @override
  String get noContactsYet => 'Chưa có ai trong danh sách, hãy chọn Người mới.';

  @override
  String get phone => 'Số điện thoại';

  @override
  String get idNumber => 'Số CCCD';

  @override
  String get personName => 'Họ tên';

  @override
  String get personNameHint => 'Nguyễn Văn A';

  @override
  String get navPeople => 'Người';

  @override
  String get addPerson => 'Thêm người';

  @override
  String get editPerson => 'Sửa thông tin';

  @override
  String get noPeopleTitle => 'Chưa có ai';

  @override
  String get noPeopleBody =>
      'Người thuê sẽ hiện ở đây khi bạn cho thuê phòng. Bạn cũng có thể tự thêm người.';

  @override
  String get notRenting => 'Không thuê gì';

  @override
  String get cannotDeleteRenting =>
      'Người này đang thuê, hãy kết thúc hợp đồng trước khi xóa.';

  @override
  String get deletePersonTitle => 'Xóa người này?';

  @override
  String get deletePersonBody => 'Người này sẽ bị xóa khỏi danh sách.';
}
