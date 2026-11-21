class StarterCategory {
  final String id;
  final String nameBn;
  final String nameEn;
  final String icon;
  final String defaultUnit;
  final List<String> suggestions;

  const StarterCategory({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.icon,
    this.defaultUnit = 'piece',
    this.suggestions = const [],
  });
}

class ProductTemplates {
  static const List<String> globalSuggestions = [
    'চাল',
    'ডাল',
    'তেল',
    'আটা',
    'ময়দা',
    'চিনি',
    'লবণ',
    'বিস্কুট',
    'চানাচুর',
    'সিঙ্গারা',
    'বাদাম',
    'সাবান',
    'শ্যাম্পু',
    'পানীয়',
    'চা',
    'কফি',
    'মসলা',
    'সবজি',
    'ফলমূল',
    'দুধ',
    'ডিম',
  ];

  static const List<StarterCategory> starterCategories = [
    StarterCategory(
      id: 'cat_rice',
      nameBn: 'চাল ও চালজাত পণ্য',
      nameEn: 'Rice & Rice Products',
      icon: 'grain',
      defaultUnit: 'kg',
      suggestions: [
        'চাল',
        'মিনিকেট চাল',
        'নাজিরশাইল চাল',
        'বাসমতী চাল',
        'পোলাও চাল',
        'চিড়া',
        'মুড়ি',
      ],
    ),
    StarterCategory(
      id: 'cat_pulses',
      nameBn: 'ডাল ও ডালজাত পণ্য',
      nameEn: 'Lentils & Pulses',
      icon: 'spa',
      defaultUnit: 'kg',
      suggestions: [
        'ডাল',
        'মসুর ডাল',
        'মুগ ডাল',
        'ছোলা ডাল',
        'খেসারি ডাল',
        'মটর ডাল',
        'বেসন',
      ],
    ),
    StarterCategory(
      id: 'cat_oil',
      nameBn: 'তেল ও ঘি',
      nameEn: 'Oil & Ghee',
      icon: 'opacity',
      defaultUnit: 'liter',
      suggestions: [
        'তেল',
        'সয়াবিন তেল',
        'সরিষার তেল',
        'ঘি',
        'পাম অয়েল',
        'অলিভ অয়েল',
      ],
    ),
    StarterCategory(
      id: 'cat_spices',
      nameBn: 'মসলা',
      nameEn: 'Spices',
      icon: 'restaurant_menu',
      defaultUnit: 'g',
      suggestions: [
        'মসলা',
        'হলুদ গুঁড়া',
        'মরিচ গুঁড়া',
        'ধনিয়া গুঁড়া',
        'জিরা গুঁড়া',
        'গরম মসলা',
        'আদা',
        'রসুন',
        'পেঁয়াজ',
      ],
    ),
    StarterCategory(
      id: 'cat_flour',
      nameBn: 'আটা ও ময়দা',
      nameEn: 'Flour & Atta',
      icon: 'bakery_dining',
      defaultUnit: 'kg',
      suggestions: [
        'আটা',
        'ময়দা',
        'গম আটা',
        'প্যাকেট আটা',
        'সুজি',
      ],
    ),
    StarterCategory(
      id: 'cat_sugar_salt',
      nameBn: 'চিনি ও লবণ',
      nameEn: 'Sugar & Salt',
      icon: 'cookie',
      defaultUnit: 'kg',
      suggestions: [
        'চিনি',
        'লবণ',
        'সাদা চিনি',
        'লাল চিনি',
        'আয়োডিনযুক্ত লবণ',
        'বিট লবণ',
      ],
    ),
    StarterCategory(
      id: 'cat_biscuits',
      nameBn: 'বিস্কুট ও বেকারি',
      nameEn: 'Biscuits & Bakery',
      icon: 'breakfast_dining',
      defaultUnit: 'packet',
      suggestions: [
        'বিস্কুট',
        'টোস্ট বিস্কুট',
        'ক্র্যাকার বিস্কুট',
        'পাউরুটি',
        'কেক',
        'ড্রাই কেক',
      ],
    ),
    StarterCategory(
      id: 'cat_snacks',
      nameBn: 'চানাচুর ও স্ন্যাকস',
      nameEn: 'Chanachur & Snacks',
      icon: 'fastfood',
      defaultUnit: 'packet',
      suggestions: [
        'চানাচুর',
        'ঝাল চানাচুর',
        'মিষ্টি চানাচুর',
        'আলুর চিপস',
        'ডালমুট',
      ],
    ),
    StarterCategory(
      id: 'cat_nuts',
      nameBn: 'বাদাম ও শুকনো খাবার',
      nameEn: 'Nuts & Dry Foods',
      icon: 'emoji_food_beverage',
      defaultUnit: 'g',
      suggestions: [
        'বাদাম',
        'চিনাবাদাম',
        'কাজুবাদাম',
        'কাঠবাদাম',
        'কিশমিশ',
        'খেজুর',
      ],
    ),
    StarterCategory(
      id: 'cat_singara_breakfast',
      nameBn: 'সিঙ্গারা ও নাস্তা',
      nameEn: 'Singara & Snacks',
      icon: 'lunch_dining',
      defaultUnit: 'piece',
      suggestions: [
        'সিঙ্গারা',
        'সমুচা',
        'পুরি',
        'প্যাটিস',
        'রোল',
      ],
    ),
    StarterCategory(
      id: 'cat_soap_detergent',
      nameBn: 'সাবান ও ডিটারজেন্ট',
      nameEn: 'Soap & Detergents',
      icon: 'soap',
      defaultUnit: 'piece',
      suggestions: [
        'সাবান',
        'গোসলের সাবান',
        'কাপড় ধোয়ার সাবান',
        'ডিটারজেন্ট পাউডার',
        'ডিশওয়াশ বার',
      ],
    ),
    StarterCategory(
      id: 'cat_cosmetics',
      nameBn: 'শ্যাম্পু ও কসমেটিকস',
      nameEn: 'Shampoo & Cosmetics',
      icon: 'face',
      defaultUnit: 'bottle',
      suggestions: [
        'শ্যাম্পু',
        'হেয়ার অয়েল',
        'বডি লোশন',
        'ট্যালকম পাউডার',
        'ফেস ওয়াশ',
      ],
    ),
    StarterCategory(
      id: 'cat_oral_care',
      nameBn: 'টুথপেস্ট ও ব্যক্তিগত পরিচর্যা',
      nameEn: 'Toothpaste & Personal Care',
      icon: 'clean_hands',
      defaultUnit: 'piece',
      suggestions: [
        'টুথপেস্ট',
        'টুথব্রাশ',
        'মাউথওয়াশ',
        'শেভিং ক্রিম',
        'রেজর',
      ],
    ),
    StarterCategory(
      id: 'cat_dairy',
      nameBn: 'দুধ ও দুগ্ধজাত পণ্য',
      nameEn: 'Milk & Dairy',
      icon: 'local_drink',
      defaultUnit: 'liter',
      suggestions: [
        'দুধ',
        'তরল দুধ',
        'গুঁড়ো দুধ',
        'মাখন',
        'পনির',
        'দই',
      ],
    ),
    StarterCategory(
      id: 'cat_beverages',
      nameBn: 'পানীয় ও জুস',
      nameEn: 'Beverages & Juice',
      icon: 'sports_bar',
      defaultUnit: 'bottle',
      suggestions: [
        'পানীয়',
        'আমের জুস',
        'কমলার জুস',
        'কোমল পানীয়',
        'এনার্জি ড্রিংক',
      ],
    ),
    StarterCategory(
      id: 'cat_tea_coffee',
      nameBn: 'চা ও কফি',
      nameEn: 'Tea & Coffee',
      icon: 'coffee',
      defaultUnit: 'packet',
      suggestions: [
        'চা',
        'কফি',
        'চা পাতা',
        'গ্রিন টি',
        'ইনস্ট্যান্ট কফি',
        'কফি মিক্স',
      ],
    ),
    StarterCategory(
      id: 'cat_water',
      nameBn: 'পানি',
      nameEn: 'Drinking Water',
      icon: 'water_drop',
      defaultUnit: 'bottle',
      suggestions: [
        'পানি ৫০০ মিলি',
        'পানি ১ লিটার',
        'পানি ২ লিটার',
        'জার পানি ৫ লিটার',
      ],
    ),
    StarterCategory(
      id: 'cat_eggs_food',
      nameBn: 'ডিম ও খাদ্যপণ্য',
      nameEn: 'Eggs & Food Items',
      icon: 'egg',
      defaultUnit: 'piece',
      suggestions: [
        'ডিম',
        'ফার্মের লাল ডিম',
        'ফার্মের সাদা ডিম',
        'দেশি মুরগির ডিম',
        'হাঁসের ডিম',
      ],
    ),
    StarterCategory(
      id: 'cat_baby_care',
      nameBn: 'শিশুদের পণ্য',
      nameEn: 'Baby Products',
      icon: 'child_care',
      defaultUnit: 'piece',
      suggestions: [
        'বেবি সিরিয়াল',
        'ডায়াপার',
        'বেবি লোশন',
        'বেবি শ্যাম্পু',
        'দুধের ফিডার',
      ],
    ),
    StarterCategory(
      id: 'cat_stationery',
      nameBn: 'স্টেশনারি',
      nameEn: 'Stationery',
      icon: 'menu_book',
      defaultUnit: 'piece',
      suggestions: [
        'খাতা',
        'বলপেন',
        'পেন্সিল',
        'স্কেল',
        'স্টেপলার',
      ],
    ),
    StarterCategory(
      id: 'cat_household',
      nameBn: 'গৃহস্থালি পণ্য',
      nameEn: 'Household Items',
      icon: 'home',
      defaultUnit: 'piece',
      suggestions: [
        'টিস্যু পেপার',
        'ম্যাচ/দিয়াশলাই',
        'মশার কয়েল',
        'ঝাড়ু',
        'লাইট/বাল্ব',
      ],
    ),
    StarterCategory(
      id: 'cat_frozen',
      nameBn: 'ফ্রোজেন খাবার',
      nameEn: 'Frozen Foods',
      icon: 'ac_unit',
      defaultUnit: 'packet',
      suggestions: [
        'ফ্রোজেন পরোটা',
        'ফ্রোজেন নাগেটস',
        'ফ্রোজেন ফ্রেঞ্চ ফ্রাই',
        'ফ্রোজেন সমুচা',
      ],
    ),
    StarterCategory(
      id: 'cat_packaged_food',
      nameBn: 'প্যাকেটজাত খাবার',
      nameEn: 'Packaged Foods',
      icon: 'inventory_2',
      defaultUnit: 'packet',
      suggestions: [
        'নুডুলস',
        'পাস্তা',
        'সুপ',
        'মেয়োনিজ',
        'টমেটো সস',
      ],
    ),
    StarterCategory(
      id: 'cat_others',
      nameBn: 'অন্যান্য',
      nameEn: 'Others',
      icon: 'category',
      defaultUnit: 'piece',
      suggestions: [
        'অন্যান্য পণ্য',
        'সাধারণ মুদি পণ্য',
      ],
    ),
  ];

  static List<String> getSuggestionsForCategory(String? categoryName) {
    if (categoryName == null || categoryName.trim().isEmpty) {
      return globalSuggestions;
    }
    final normalized = categoryName.trim().toLowerCase();
    for (final cat in starterCategories) {
      if (cat.nameBn.toLowerCase().contains(normalized) ||
          normalized.contains(cat.nameBn.toLowerCase()) ||
          cat.nameEn.toLowerCase().contains(normalized) ||
          normalized.contains(cat.nameEn.toLowerCase())) {
        return cat.suggestions;
      }
    }
    return globalSuggestions;
  }
}
