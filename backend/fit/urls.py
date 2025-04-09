from django.conf import settings
from django.conf.urls.static import static
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PostViewSet, LikeViewSet, CommentViewSet, MediaViewSet
from fit.views import (
    SendPasswordResetEmailView, UserChangePasswordView, UserLoginView,
    UserProfileView, UserRegistrationView, UserPasswordResetView,
    WorkoutView, ExerciseView, ProgressView, GoalView, NutritionView, ActivityView,
    FriendshipView, FollowView, MessageView, ChallengeView, AnalyticsView
)

router = DefaultRouter()
router.register(r'posts', PostViewSet)
router.register(r'likes', LikeViewSet)
router.register(r'comments', CommentViewSet)
router.register(r'media', MediaViewSet)

urlpatterns = [
    # Authentication URLs
    path('register/', UserRegistrationView.as_view(), name='register'),
    path('login/', UserLoginView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('changepassword/', UserChangePasswordView.as_view(), name='changepassword'),
    path('send-reset-password-email/', SendPasswordResetEmailView.as_view(), name='send-reset-password-email'),
    path('reset-password/<uid>/<token>/', UserPasswordResetView.as_view(), name='reset-password'),

    # Fit App URLs
    path('workouts/', WorkoutView.as_view(), name='workouts'),
    path('workouts/<int:workout_id>/exercises/', ExerciseView.as_view(), name='exercises'),
    path('progress/', ProgressView.as_view(), name='progress'),
    path('goals/', GoalView.as_view(), name='goals'),
    path('nutrition/', NutritionView.as_view(), name='nutrition'),
    path('activities/', ActivityView.as_view(), name='activities'),
    path('friends/', FriendshipView.as_view(), name='friends'),
    path('follow/', FollowView.as_view(), name='follow'),
    path('message/', MessageView.as_view(), name='message'),
    path('challenges/', ChallengeView.as_view(), name='challenges'),
    path('analytics/', AnalyticsView.as_view(), name='analytics'),
    path('', include(router.urls)),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
