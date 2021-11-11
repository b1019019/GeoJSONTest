//
//  ViewController.swift
//  GeoJSONTest
//
//  Created by 山田純平 on 2021/09/29.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let displayObjects = parseGeoJSON()
        mapView.addOverlays(displayObjects)
    }
    
    func parseGeoJSON() -> [MKOverlay] {
        //URL取得
        guard let url = Bundle.main.url(forResource: "test", withExtension: "json") else {
            fatalError("Unable to get geojson")
        }
        //NSGeoJSONObjectにデコード
        var geoJson = [MKGeoJSONObject]()
        do {
            let data = try Data(contentsOf: url)
            geoJson = try MKGeoJSONDecoder().decode(data)
        } catch {
            fatalError("Unable to decode geojson")
        }
        //MKGeoJSONFeature：
        //MKPolygon
        //geoJSONObject(プロトコル)をMKGeoJSONFeature(クラス)に変
        var overlays = [MKOverlay]()
        
        for item in geoJson {
            if let feature = item as? MKGeoJSONFeature {
                //geometry: [MKShape & MKGeoJSONObject]
                //MKShape：全ての形状のオーバーレイオブジェクトの基本的なプロパティを定義する抽象クラス
                //右プロトコルを継承した左クラスという意味。
                //このような書き方をプロトコルコンポジションというらしい。
                for geo in feature.geometry {
                    //MKPolygon：占有領域を持つオーバーレイオブジェクト(三角、四角など)
                    //なぜMKPolygonがMKOverlayに代入できるのか
                    if let polygon = geo as? MKPolygon {
                        overlays.append(polygon)
                    } else if let point = geo as? MKPointAnnotation {
                        //pointAnnotations.append(point)
                        overlays.append(MKCircle(center: point.coordinate, radius: 1000))
                        print(point)
                        print(overlays)
                    }
                }
            }
        }
        return overlays
    }


}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polygon = overlay as? MKPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.fillColor = UIColor.blue
            renderer.strokeColor = UIColor.black
            return renderer
        } else if let circle = overlay as? MKCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.fillColor = UIColor.blue
            renderer.strokeColor = UIColor.black
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

