from django.apps import AppConfig

class FitnessAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'fitness_app'
    
    def ready(self):
        import fitness_app.signals