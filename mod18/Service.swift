//
//  Service.swift
//  mod18
//
//  Created by Natalia Shevaldina on 01.05.2022.
//

import UIKit

struct Service {
    
    var url = String()
    
    func loadImage(urlString: String) -> UIImage? {
        guard
            let url = URL(string: urlString),
            let data = try? Data(contentsOf: url)
        else {
            print("Ошибка, не удалось загрузить изображение")
            return nil
        }
        return UIImage(data: data)
    }
}
