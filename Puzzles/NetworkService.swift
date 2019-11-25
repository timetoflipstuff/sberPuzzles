//
//  NetworkService.swift
//  Puzzles
//
//  Created by Leonid Serebryanyy on 18.11.2019.
//  Copyright © 2019 Leonid Serebryanyy. All rights reserved.
//

import Foundation
import UIKit


class NetworkService {
	
	let session: URLSession
	
	private var queue = DispatchQueue(label: "com.sber.puzzless", qos: .default, attributes: .concurrent)

	
	init() {
		session = URLSession(configuration: .default)
	}
	
	
	// MARK:- Первое задание
	
	///  Вот здесь должны загружаться 4 картинки и совмещаться в одну.
	///  Для выполнения этой задачи вам можно изменять только этот метод.
	///  Метод, соединяющий картинки в одну, уже написан (вызывается в конце).
	///  Ответ передайте в completion.
	///  Помните, что надо сделать так, чтобы метод работал как можно быстрее.
	public func loadPuzzle(completion: @escaping (Result<UIImage, Error>) -> ()) {
		// это адреса картинок. они работающие, всё ок!
		let firstURL = URL(string: "https://i.imgur.com/JnY1dY7.jpg")!
		let secondURL = URL(string: "https://i.imgur.com/S93pvex.jpg")!
		let thirdURL = URL(string: "https://i.imgur.com/pvCHGsL.jpg")!
		let fourthURL = URL(string: "https://i.imgur.com/DgijrVE.jpg")!
		let urls = [firstURL, secondURL, thirdURL, fourthURL]
        
		// в этот массив запишите итоговые картинки
			var results = [UIImage]()

        let dispatchGroup = DispatchGroup()
        
        let puzzleQueue = DispatchQueue(label: "Using .com.sber.puzzless doesn't work sooo", qos: .default, attributes: .concurrent)
        
        
            for i in 0..<urls.count {
                dispatchGroup.enter()
                puzzleQueue.async {
                
                let task = self.session.dataTask(with: urls[i]) { (data: Data?, response: URLResponse?, error: Error?) in
                    
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data, let img = UIImage(data: data) else {
                        return
                    }
                    results.append(img)
                    dispatchGroup.leave()
                }
                task.resume()
            }
            
        }
	
        dispatchGroup.notify(queue: puzzleQueue) {
            if let merged = ImagesServices.image(byCombining: results) {
                completion(.success(merged))
            }
        }
	}
	
	
	// MARK:- Второе задание
	
	
	///  Здесь задание такое:
	///  У вас есть ключ keyURL, по которому спрятан клад.
	///  Верните картинку с этим кладом в completion
    public func loadQuiz(completion: @escaping(Result<UIImage, Error>) -> ()) {
        let keyURL = URL(string: "https://sberschool-c264c.firebaseio.com/enigma.json?avvrdd_token=AIzaSyDqbtGbRFETl2NjHgdxeOGj6UyS3bDiO-Y")!
		
		// Вам придёт строка, её надо прочитать с помощью JSONDecoder (ну как мы всегда читали с файрбэйза)
        session.dataTask(with: keyURL) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                return
            }
            do {
                let jsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let img = UIImage(data: try Data(contentsOf: URL(string: jsonData as! String)!))
                completion(.success(img!))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()

    }

}
