class SyriaArea {
  final String id;
  final String nameAr;
  final String nameEn;

  const SyriaArea({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  String label(bool isAr) => isAr ? nameAr : nameEn;
}

class SyriaCity {
  final String id;
  final String nameAr;
  final String nameEn;
  final List<SyriaArea> areas;

  const SyriaCity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.areas,
  });

  String label(bool isAr) => isAr ? nameAr : nameEn;
}

/// مدن وأحياء سوريا لـ onboarding السائق — متوافقة مع أسواق Admin.
abstract final class SyriaCitiesCatalog {
  static const List<SyriaCity> cities = [
    SyriaCity(
      id: 'damascus',
      nameAr: 'دمشق',
      nameEn: 'Damascus',
      areas: [
        SyriaArea(id: 'barzeh', nameAr: 'برزة', nameEn: 'Barzeh'),
        SyriaArea(id: 'mazzeh', nameAr: 'المزة', nameEn: 'Mazzeh'),
        SyriaArea(id: 'kafr_sousa', nameAr: 'كفرسوسة', nameEn: 'Kafr Sousa'),
        SyriaArea(id: 'abu_rummaneh', nameAr: 'أبو رمانة', nameEn: 'Abu Rummaneh'),
        SyriaArea(id: 'midane', nameAr: 'الميدان', nameEn: 'Midane'),
        SyriaArea(id: 'rukn_al_din', nameAr: 'ركن الدين', nameEn: 'Rukn al-Din'),
        SyriaArea(id: 'ash_al_warwar', nameAr: 'عش الورور', nameEn: 'Ash al-Warwar'),
        SyriaArea(id: 'qadam', nameAr: 'القدم', nameEn: 'Qadam'),
        SyriaArea(id: 'bab_touma', nameAr: 'باب توما', nameEn: 'Bab Touma'),
        SyriaArea(id: 'mezzeh_86', nameAr: 'المزة 86', nameEn: 'Mazzeh 86'),
      ],
    ),
    SyriaCity(
      id: 'rif_damascus',
      nameAr: 'ريف دمشق',
      nameEn: 'Rif Damascus',
      areas: [
        SyriaArea(id: 'al_tal', nameAr: 'التل', nameEn: 'Al-Tal'),
        SyriaArea(id: 'manin', nameAr: 'منين', nameEn: 'Manin'),
        SyriaArea(id: 'saydnaya', nameAr: 'صيدنايا', nameEn: 'Saydnaya'),
        SyriaArea(id: 'maarraba', nameAr: 'معربا', nameEn: 'Maarraba'),
        SyriaArea(id: 'qudsaya', nameAr: 'قدسيا', nameEn: 'Qudsaya'),
        SyriaArea(id: 'jaramana', nameAr: 'جرمانا', nameEn: 'Jaramana'),
        SyriaArea(id: 'sahnaya', nameAr: 'صحنايا', nameEn: 'Sahnaya'),
        SyriaArea(id: 'daraya', nameAr: 'داريا', nameEn: 'Daraya'),
        SyriaArea(id: 'douma', nameAr: 'دوما', nameEn: 'Douma'),
        SyriaArea(id: 'harasta', nameAr: 'حرستا', nameEn: 'Harasta'),
      ],
    ),
    SyriaCity(
      id: 'aleppo',
      nameAr: 'حلب',
      nameEn: 'Aleppo',
      areas: [
        SyriaArea(id: 'aziziyah', nameAr: 'العزيزية', nameEn: 'Aziziyah'),
        SyriaArea(id: 'salaheddine', nameAr: 'صلاح الدين', nameEn: 'Salaheddine'),
        SyriaArea(id: 'al_shaar', nameAr: 'الشعار', nameEn: 'Al-Shaar'),
        SyriaArea(id: 'al_hamdaniyah', nameAr: 'الحمدانية', nameEn: 'Al-Hamdaniyah'),
        SyriaArea(id: 'al_sabeel', nameAr: 'السبيل', nameEn: 'Al-Sabeel'),
        SyriaArea(id: 'new_aleppo', nameAr: 'حلب الجديدة', nameEn: 'New Aleppo'),
        SyriaArea(id: 'syrian_hospital', nameAr: 'المشفى السوري', nameEn: 'Syrian Hospital area'),
        SyriaArea(id: 'jamiliyah', nameAr: 'الجميلية', nameEn: 'Jamiliyah'),
      ],
    ),
    SyriaCity(
      id: 'homs',
      nameAr: 'حمص',
      nameEn: 'Homs',
      areas: [
        SyriaArea(id: 'al_waer', nameAr: 'الوعر', nameEn: 'Al-Waer'),
        SyriaArea(id: 'al_inshaat', nameAr: 'الإنشاءات', nameEn: 'Al-Inshaat'),
        SyriaArea(id: 'bab_tadmor', nameAr: 'باب تدمر', nameEn: 'Bab Tadmor'),
        SyriaArea(id: 'al_zahraa', nameAr: 'الزهراء', nameEn: 'Al-Zahraa'),
        SyriaArea(id: 'city_center_homs', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'al_ghouta_homs', nameAr: 'الغوطة', nameEn: 'Al-Ghouta'),
      ],
    ),
    SyriaCity(
      id: 'hama',
      nameAr: 'حماة',
      nameEn: 'Hama',
      areas: [
        SyriaArea(id: 'city_center_hama', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'salamiyah_road', nameAr: 'طريق سلمية', nameEn: 'Salamiyah Road'),
        SyriaArea(id: 'karam_al_leyl', nameAr: 'كرم الليل', nameEn: 'Karam al-Leyl'),
        SyriaArea(id: 'taleol', nameAr: 'الطالع', nameEn: 'Taleol'),
        SyriaArea(id: 'hader', nameAr: 'حادر', nameEn: 'Hader'),
      ],
    ),
    SyriaCity(
      id: 'latakia',
      nameAr: 'اللاذقية',
      nameEn: 'Latakia',
      areas: [
        SyriaArea(id: 'city_center_latakia', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'al_ziraa', nameAr: 'الزراعة', nameEn: 'Al-Ziraa'),
        SyriaArea(id: 'salibeh', nameAr: 'الصليبة', nameEn: 'Salibeh'),
        SyriaArea(id: 'project_square', nameAr: 'ساحة المشاريع', nameEn: 'Project Square'),
        SyriaArea(id: 'corniche_latakia', nameAr: 'الكورنيش', nameEn: 'Corniche'),
      ],
    ),
    SyriaCity(
      id: 'tartus',
      nameAr: 'طرطوس',
      nameEn: 'Tartus',
      areas: [
        SyriaArea(id: 'city_center_tartus', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'corniche_tartus', nameAr: 'الكورنيش', nameEn: 'Corniche'),
        SyriaArea(id: 'old_tartus', nameAr: 'المدينة القديمة', nameEn: 'Old City'),
        SyriaArea(id: 'banias_road', nameAr: 'طريق بانياس', nameEn: 'Banias Road'),
      ],
    ),
    SyriaCity(
      id: 'daraa',
      nameAr: 'درعا',
      nameEn: 'Daraa',
      areas: [
        SyriaArea(id: 'city_center_daraa', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'al_sad', nameAr: 'السد', nameEn: 'Al-Sad'),
        SyriaArea(id: 'tafas_road', nameAr: 'طريق طفس', nameEn: 'Tafas Road'),
        SyriaArea(id: 'naima', nameAr: 'نعمة', nameEn: 'Naima'),
      ],
    ),
    SyriaCity(
      id: 'sweida',
      nameAr: 'السويداء',
      nameEn: 'Sweida',
      areas: [
        SyriaArea(id: 'city_center_sweida', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'salkhad_road', nameAr: 'طريق صلخد', nameEn: 'Salkhad Road'),
        SyriaArea(id: 'shahba', nameAr: 'شهبا', nameEn: 'Shahba'),
      ],
    ),
    SyriaCity(
      id: 'deir_ez_zor',
      nameAr: 'دير الزور',
      nameEn: 'Deir ez-Zor',
      areas: [
        SyriaArea(id: 'city_center_deir', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'al_joura', nameAr: 'الجورة', nameEn: 'Al-Joura'),
        SyriaArea(id: 'al_qusour', nameAr: 'القصور', nameEn: 'Al-Qusour'),
      ],
    ),
    SyriaCity(
      id: 'hasakah',
      nameAr: 'الحسكة',
      nameEn: 'Hasakah',
      areas: [
        SyriaArea(id: 'city_center_hasakah', nameAr: 'وسط المدينة', nameEn: 'City Center'),
        SyriaArea(id: 'al_nashwa', nameAr: 'النشوة', nameEn: 'Al-Nashwa'),
        SyriaArea(id: 'ghweiran', nameAr: 'غويران', nameEn: 'Ghweiran'),
      ],
    ),
  ];

  static SyriaCity? cityById(String? id) {
    if (id == null) return null;
    for (final c in cities) {
      if (c.id == id) return c;
    }
    return null;
  }

  static List<SyriaArea> areasFor(String? cityId) =>
      cityById(cityId)?.areas ?? const [];
}
