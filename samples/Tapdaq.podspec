Pod::Spec.new do |s|

  s.name         = "Tapdaq"
  s.version      = "6.3.2"
  s.summary      = "Tapdaq SDK"
  s.description  = <<-DESC
  The official Tapdaq iOS SDK
                   DESC
  s.homepage     = "https://tapdaq.com"
  s.license      = {
    :type => "Commercial",
    :text => "https://tapdaq.com/terms-and-conditions"
  }
  s.author             = { "Tapdaq" => "support@tapdaq.com" }
  s.social_media_url   = "http://twitter.com/tapdaq"

  s.platform     = :ios, "9.0"
  s.source       = { :http => "https://s3.eu-west-2.amazonaws.com/tapdaq-ios-sdk/#{s.version}/sdk/sdk_universal_#{s.version}.zip" }

  s.default_subspec = "SDK"

  s.subspec "SDK" do |sdk|
    sdk.frameworks = "Foundation", "UIKit", "QuartzCore", "AdSupport", "Security", "SystemConfiguration", 
    "MobileCoreServices", "StoreKit", "CoreTelephony", "AVFoundation"
    sdk.vendored_frameworks = 'Tapdaq.framework'
    sdk.xcconfig = { "OTHERLD_FLAGS" => "-ObjC" }
    sdk.requires_arc = true
  end

  s.subspec "AdColony" do |adcolony|
    adcolony.dependency 'Tapdaq/AdColonyAdapter'
    adcolony.dependency "AdColony", "3.3.4"
  end
  
  s.subspec "AdColonyAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/AdColonyAdapter.framework"
  end

  s.subspec "AdMob" do |admob|
    admob.dependency 'Tapdaq/AdMobAdapter'
    admob.dependency "Google-Mobile-Ads-SDK", "7.34.0"
  end
  
  s.subspec "AdMobAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/AdMobAdapter.framework"
  end

  s.subspec "AppLovin" do |applovin|
    applovin.dependency 'Tapdaq/AppLovinAdapter'
    applovin.dependency "AppLovinSDK", "5.0.1"
  end
  
  s.subspec "AppLovinAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/AppLovinAdapter.framework"
  end

  s.subspec "Chartboost" do |chartboost|
    chartboost.dependency 'Tapdaq/ChartboostAdapter'
    chartboost.dependency "ChartboostSDK", "7.2.0"
  end
  
  s.subspec "ChartboostAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/ChartboostAdapter.framework"
  end

  s.subspec "FAN" do |fan|
    fan.dependency 'Tapdaq/FANAdapter'
    fan.dependency "FBAudienceNetwork", "4.99.3"
  end
  
  s.subspec "FANAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/FANAdapter.framework"
  end

#  s.subspec "HyprMx" do |hyprmx|
#    inmobi.dependency 'Tapdaq/HyprMxAdapter'
#    inmobi.dependency "InMobiSDK", "7.2.0"
#  end
  
#  s.subspec "HyprMxAdapter" do |adapter|
#    adapter.vendored_frameworks = "Adapters/HyprMxAdapter.framework"
#  end

  s.subspec "InMobi" do |inmobi|
    inmobi.dependency 'Tapdaq/InMobiAdapter'
    inmobi.dependency "InMobiSDK", "7.2.0"
  end
  
  s.subspec "InMobiAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/InMobiAdapter.framework"
  end

  s.subspec "IronSource" do |ironsource|
    ironsource.dependency 'Tapdaq/IronSourceAdapter'
    ironsource.dependency "IronSourceSDK", "6.7.9"
  end
  
  s.subspec "IronSourceAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/IronSourceAdapter.framework"
  end

  s.subspec "Kiip" do |kiip|
    kiip.dependency 'Tapdaq/KiipAdapter'
    kiip.dependency "KiipSDK", "3.0.3"
  end
  
  s.subspec "KiipAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/KiipAdapter.framework"
  end
  
  s.subspec "MoPub" do |mopub|
    mopub.dependency 'Tapdaq/MoPubAdapter'
    mopub.dependency "mopub-ios-sdk", "5.3.0"
  end
  
  s.subspec "MoPubAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/MoPubAdapter.framework"
  end

  s.subspec "Receptiv" do |receptiv|
    receptiv.dependency 'Tapdaq/ReceptivAdapter'
    receptiv.dependency "MediaBrix", "1.8.3.001"
  end
  
  s.subspec "ReceptivAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/ReceptivAdapter.framework"
  end

  s.subspec "Tapjoy" do |tapjoy|
    tapjoy.dependency 'Tapdaq/TapjoyAdapter'
    tapjoy.dependency "TapjoySDK", "12.0.0"
  end
  
  s.subspec "TapjoyAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/TapjoyAdapter.framework"
  end

  s.subspec "UnityAds" do |unityads|
    unityads.dependency 'Tapdaq/UnityAdsAdapter'
    unityads.dependency "UnityAds", "2.3.0"
  end
  
  s.subspec "UnityAdsAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/UnityAdsAdapter.framework"
  end

  s.subspec "Vungle" do |vungle|
    vungle.dependency 'Tapdaq/VungleAdapter'
    vungle.dependency "VungleSDK-iOS", "6.2.0"
  end
  
  s.subspec "VungleAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/VungleAdapter.framework"
  end

  s.subspec "YouAppi" do |youappi|
    youappi.dependency 'Tapdaq/YouAppiAdapter'
    youappi.dependency "YouAppiMoatSDK", "4.3.1"
  end
  
  s.subspec "YouAppiAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/YouAppiAdapter.framework"
    adapter.user_target_xcconfig = { 'ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES' => 'YES' }
  end

  s.subspec "ZPlay" do |zplay|
    zplay.dependency 'Tapdaq/ZPlayAdapter'
    zplay.dependency "PlayableAds", "2.0.7"
  end
  
  s.subspec "ZPlayAdapter" do |adapter|
    adapter.vendored_frameworks = "Adapters/ZPlayAdapter.framework"
  end
end
