/**
 * TikTok Events SDK - Cordova Plugin
 * 
 * Installation:
 *   cordova plugin add cordova-plugin-tiktok-events \
 *     --variable TIKTOK_ACCESS_TOKEN=xxx \
 *     --variable TIKTOK_APP_ID=xxx \
 *     --variable TIKTOK_TIKTOK_APP_ID=xxx
 * 
 * Usage:
 *   TikTokEvents.requestTrackingAuthorization(success, error);
 *   TikTokEvents.initialize({ debug: true }, success, error);
 *   TikTokEvents.trackEvent('Purchase', { value: 9.99, currency: 'EUR' }, success, error);
 */

var exec = require('cordova/exec');

var TikTokEvents = {
    
    /**
     * Initialize the TikTok Events SDK
     * @param {Object} options - Configuration options
     * @param {string} options.accessToken - TikTok Access Token (optional if set via variable)
     * @param {string} options.appId - TikTok App ID (optional if set via variable)
     * @param {string} options.tiktokAppId - TikTok TikTok App ID (optional if set via variable)
     * @param {boolean} options.debug - Enable debug mode (optional, default: false)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    initialize: function(options, success, error) {
        options = options || {};
        exec(success, error, 'TikTokEvents', 'initialize', [options]);
    },
    
    /**
     * Request App Tracking Transparency authorization (iOS 14+)
     * Call this before initialize() for best results
     * @param {Function} success - Success callback with authorization status
     * @param {Function} error - Error callback
     */
    requestTrackingAuthorization: function(success, error) {
        exec(success, error, 'TikTokEvents', 'requestTrackingAuthorization', []);
    },
    
    /**
     * Track a standard or custom event
     * @param {string} eventName - Event name (e.g., 'Purchase', 'AddToCart', 'ViewContent')
     * @param {Object} properties - Event properties (optional)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     * 
     * Standard Events (use TTEventName constants):
     *   - LaunchAPP, InstallApp
     *   - Registration, Login
     *   - Search
     *   - AddPaymentInfo
     *   - Subscribe, StartTrial
     *   - CompleteTutorial, AchieveLevel
     *   - CreateGroup, JoinGroup
     *   - SpendCredits, UnlockAchievement
     *   - GenerateLead, Rate
     * 
     * Common Properties:
     *   - value (number): Monetary value
     *   - currency (string): ISO currency code (EUR, USD, etc.)
     *   - content_type (string): Type of content
     *   - content_id (string): Content identifier
     *   - description (string): Event description
     */
    trackEvent: function(eventName, properties, success, error) {
        if (!eventName) {
            if (error) error('eventName is required');
            return;
        }
        properties = properties || {};
        exec(success, error, 'TikTokEvents', 'trackEvent', [eventName, properties]);
    },
    
    /**
     * Track a purchase event (convenience method)
     * @param {number} value - Purchase value
     * @param {string} currency - Currency code (default: 'EUR')
     * @param {Object} additionalProperties - Additional properties (optional)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    trackPurchase: function(value, currency, additionalProperties, success, error) {
        var properties = Object.assign({
            value: value,
            currency: currency || 'EUR'
        }, additionalProperties || {});
        
        this.trackEvent('Purchase', properties, success, error);
    },
    
    /**
     * Track registration completion
     * @param {string} method - Registration method (e.g., 'email', 'apple', 'google')
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    trackRegistration: function(method, success, error) {
        this.trackEvent('Registration', { method: method }, success, error);
    },
    
    /**
     * Track content view
     * @param {string} contentId - Content identifier
     * @param {string} contentType - Content type
     * @param {Object} additionalProperties - Additional properties (optional)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    trackViewContent: function(contentId, contentType, additionalProperties, success, error) {
        var properties = Object.assign({
            content_id: contentId,
            content_type: contentType
        }, additionalProperties || {});
        
        this.trackEvent('ViewContent', properties, success, error);
    },
    
    /**
     * Track subscription
     * @param {number} value - Subscription value
     * @param {string} currency - Currency code
     * @param {string} subscriptionId - Subscription identifier
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    trackSubscription: function(value, currency, subscriptionId, success, error) {
        var properties = {
            value: value,
            currency: currency || 'EUR',
            subscription_id: subscriptionId
        };
        
        this.trackEvent('Subscribe', properties, success, error);
    },
    
    /**
     * Identify user (for advanced matching)
     * @param {Object} userInfo - User information
     * @param {string} userInfo.email - User email (will be hashed by SDK)
     * @param {string} userInfo.phone - User phone (will be hashed by SDK)
     * @param {string} userInfo.externalId - External user ID
     * @param {string} userInfo.externalUserName - External username
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    identifyUser: function(userInfo, success, error) {
        exec(success, error, 'TikTokEvents', 'identifyUser', [userInfo || {}]);
    },
    
    /**
     * Clear user identity (on logout)
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    clearUser: function(success, error) {
        exec(success, error, 'TikTokEvents', 'clearUser', []);
    },
    
    /**
     * Get TikTok SDK version
     * @param {Function} success - Success callback with version string
     * @param {Function} error - Error callback
     */
    getVersion: function(success, error) {
        exec(success, error, 'TikTokEvents', 'getVersion', []);
    },
    
    /**
     * Check if SDK is initialized
     * @param {Function} success - Success callback with boolean
     * @param {Function} error - Error callback
     */
    isInitialized: function(success, error) {
        exec(success, error, 'TikTokEvents', 'isInitialized', []);
    },
    
    /**
     * Enable/disable debug logging
     * @param {boolean} enabled - Enable debug mode
     * @param {Function} success - Success callback
     * @param {Function} error - Error callback
     */
    setDebug: function(enabled, success, error) {
        exec(success, error, 'TikTokEvents', 'setDebug', [enabled]);
    }
};

module.exports = TikTokEvents;
