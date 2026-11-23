import '../data/models.dart';
import '../l10n/app_localizations.dart';

/// Starting categories for a new book. Names come from the current
/// language because they become the user's own data once saved.
List<CategorySeed> categorySeedsFor(
  BookTemplate template,
  AppLocalizations l10n,
) {
  const income = CategoryDirection.income;
  const expense = CategoryDirection.expense;

  return switch (template) {
    BookTemplate.rental => [
        CategorySeed(l10n.catRent, income),
        CategorySeed(l10n.catElectricity, income),
        CategorySeed(l10n.catWater, income),
        CategorySeed(l10n.catInternet, income),
        CategorySeed(l10n.catOtherIncome, income),
        CategorySeed(l10n.catRepairs, expense),
        CategorySeed(l10n.catOtherExpense, expense),
      ],
    BookTemplate.trading => [
        CategorySeed(l10n.catSales, income),
        CategorySeed(l10n.catOtherIncome, income),
        CategorySeed(l10n.catIngredients, expense),
        CategorySeed(l10n.catPackaging, expense),
        CategorySeed(l10n.catPremises, expense),
        CategorySeed(l10n.catWages, expense),
        CategorySeed(l10n.catOtherExpense, expense),
      ],
    BookTemplate.blank => [
        CategorySeed(l10n.catOtherIncome, income),
        CategorySeed(l10n.catOtherExpense, expense),
      ],
  };
}
