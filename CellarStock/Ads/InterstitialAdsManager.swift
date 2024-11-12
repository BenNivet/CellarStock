//
//  InterstitialAdsManager.swift
//  CellarStock
//
//  Created by CANTE Benjamin  on 20/10/2024.
//

import FirebaseAnalytics
import Foundation
import GoogleMobileAds

@MainActor
class InterstitialAdsManager: NSObject, ObservableObject {
    
    @Published var interstitialAdLoaded = false
    var interstitialAd: GADInterstitialAd?
    
#if DEBUG
    // TEST Id
    private let interstitialId = "ca-app-pub-3940256099942544/4411468910"
#else
    // PROD Id
    private let interstitialId = "ca-app-pub-1362150666996278/3489136171"
#endif
    
    override init() {
        super.init()
        loadInterstitialAd()
    }
    
    func loadInterstitialAd() {
        GADInterstitialAd.load(withAdUnitID: interstitialId, request: GADRequest()) { [weak self] ad, error in
            guard let self else { return }
            if let error {
                print("🔴: \(error.localizedDescription)")
                interstitialAdLoaded = false
                Analytics.logEvent(LogEvent.adError, parameters: nil)
                return
            }
            print("🟢: Loading succeeded")
            interstitialAd = ad
            interstitialAd?.fullScreenContentDelegate = self
            interstitialAdLoaded = true
            if ad != nil {
                Analytics.logEvent(LogEvent.adSuccess, parameters: nil)
            } else {
                Analytics.logEvent(LogEvent.adNil, parameters: nil)
            }
        }
    }
    
    func displayInterstitialAd() {
        guard let root = UIApplication.shared.windows.first?.rootViewController
        else { return }
        
        if let interstitialAd {
            interstitialAd.present(fromRootViewController: root)
            self.interstitialAd = nil
        }
    }
}

extension InterstitialAdsManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("🟡: Failed to display interstitial ad")
        Analytics.logEvent(LogEvent.displayAdError, parameters: nil)
        loadInterstitialAd()
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("🤩: Displayed an interstitial ad")
        Analytics.logEvent(LogEvent.displayAdSuccess, parameters: nil)
        self.interstitialAd = nil
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("😔: Interstitial ad closed")
    }
}
