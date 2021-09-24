//
//  WeatherTableViewCell.swift
//  Weather
//
//  Created by Anh Tran on 23/09/2021.
//

import UIKit
import RxSwift
class WeatherTableViewCell: UITableViewCell {
    static let identifier: String = "WeatherTableViewCell"
    
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var dateValue: UILabel!
    @IBOutlet weak var tempTitle: UILabel!
    @IBOutlet weak var tempValue: UILabel!
    @IBOutlet weak var presureTitle: UILabel!
    @IBOutlet weak var presureValue: UILabel!
    @IBOutlet weak var humidityTitle: UILabel!
    @IBOutlet weak var humidityValue: UILabel!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var descriptionValue: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    
    private lazy var dateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM y"
        return dateFormatter
    }()
    
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        weatherIcon.image = nil
        disposeBag = DisposeBag()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI() {
        dateTitle.text = "Date:"
        tempTitle.text = "Average Temperature:"
        presureTitle.text = "Pressure:"
        humidityTitle.text = "Humidity:"
        descriptionTitle.text = "Description:"

    }
    
    func bindModel(_ model: WeatherDisplayModel) {
        ImageLoader.shared.loadImage(from: model.iconUrl,size: weatherIcon.frame.size)
            .subscribe (onNext:{ [weak self] image in
                guard let self = self,
                      let image = image else {
                    return
                }
                DispatchQueue.main.async {
                    self.weatherIcon.image = image
                }
            }).disposed(by: disposeBag)
        
        tempValue.text = "\(model.averageTemp)"
        dateValue.text = dateFormatter.string(from: Date(timeIntervalSince1970: model.date))
        presureValue.text = "\(model.pressure)"
        humidityValue.text = "\(model.humidity)%"
        descriptionValue.text = model.description
        
    }
    
}
