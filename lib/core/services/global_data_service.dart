import 'package:flutter/foundation.dart';
import '../../data/services/wasi_api_service.dart';
import '../constants/app_constants.dart';

class GlobalDataService {
  static final GlobalDataService _instance = GlobalDataService._internal();
  factory GlobalDataService() => _instance;
  GlobalDataService._internal();

  List<Map<String, dynamic>> _cities = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getter para acceder a las ciudades desde cualquier parte
  List<Map<String, dynamic>> get cities => _cities;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Inicializa los datos globales al arrancar la aplicación
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🌍 GlobalDataService ya inicializado');
      return; // Ya inicializado
    }
    
    _isLoading = true;
    
    try {
      debugPrint('🌍 Iniciando carga de datos globales...');
      
      // Verificar que las variables de entorno estén cargadas
      if (AppConstants.wasiApiToken.isEmpty) {
        debugPrint('❌ WASI API Token no está disponible');
        throw Exception('WASI API Token no configurado');
      }
      
      // Crear instancia del servicio API
      final apiService = WasiApiService(
        apiToken: AppConstants.wasiApiToken,
        companyId: AppConstants.wasiApiId,
      );
      
      // Cargar ciudades
      debugPrint('🏙️ Cargando ciudades...');
      _cities = await apiService.getCities();
      
      debugPrint('✅ Ciudades cargadas: ${_cities.length}');
      if (_cities.isNotEmpty) {
        debugPrint('📍 Primera ciudad: ${_cities.first}');
      }
      
      _isInitialized = true;
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error cargando datos globales: $e');
      debugPrint('Stack trace: $stackTrace');
      // En caso de error, inicializar con lista vacía
      _cities = [];
      _isInitialized = false; // Permitir reintento
    } finally {
      _isLoading = false;
    }
  }

  /// Refresca los datos globales
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  /// Busca una ciudad por nombre
  Map<String, dynamic>? findCityByName(String name) {
    try {
      return _cities.firstWhere(
        (city) => city['name']?.toString().toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtiene nombres de ciudades como lista de strings
  List<String> get cityNames {
    return _cities.map((city) => city['name'] as String).toList();
  }

  /// Filtra ciudades por texto
  List<String> filterCities(String query) {
    if (query.isEmpty) return cityNames;
    
    return cityNames.where((cityName) {
      return cityName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
