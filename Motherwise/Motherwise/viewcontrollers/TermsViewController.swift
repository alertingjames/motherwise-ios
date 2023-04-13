//
//  TermsViewController.swift
//  Motherwise
//
//  Created by Andre on 9/11/20.
//  Copyright © 2020 VaCay. All rights reserved.
//

import UIKit

class TermsViewController: BaseViewController {
    
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var textBox: UITextView!
    @IBOutlet weak var agreeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if gNote != ""{
            showToast(msg: gNote)
            gNote = ""
        }
        
        lbl_title.text = "term_conditions".localized().uppercased()

        setRoundShadowButton(button: agreeButton, corner: agreeButton.frame.height / 2)
        agreeButton.setTitle("accept".localized(), for: .normal)
        
        textBox.text = "Thank you for signing up for the Nest!\n\n***By signing up to the Nest, you are agreeing to not engage in any type of:***\n\n"
        textBox.text = textBox.text + "- hate speech\n\n- cyberbullying\n\n- solicitation and/or selling of goods or services\n\n- posting content inappropriate for our diverse community including but not limited to political or religious views\n\n"
        textBox.text = textBox.text + "We want The Nest to be a safe place for support and inspiration. Help us foster this community and please respect everyone on The Nest.\n\n"
        textBox.text = textBox.text + "If you find any content abusive or violationg the terms, please report it to the MotherWise Administrator.\n\n"
//        textBox.text = textBox.text + "Please watch this video to see how to login: https://vimeo.com/430742850\n\n"
        textBox.text = textBox.text + "If you have any question, please contact us:\n\n"
        textBox.text = textBox.text + "E-mail: motherwisecolorado@gmail.com\n\n"
        textBox.text = textBox.text + "Phone number: 720-504-4624"
        
        textBox.text = textBox.text + "\n\n\n¡Gracias por registrarse en el Nido!\n\n***Al registrarse al Nido, acepta no participar en ningún tipo de:***\n\n"
        textBox.text = textBox.text + "- El discurso del odio\n\n- ciberacoso\n\n- solicitud y/o venta de bienes o servicios\n\n- publicar contenido inapropiado para nuestra diversa comunidad, incluidos, entre otros, opiniones políticas o religiosas\n\n"
        textBox.text = textBox.text + "Queremos que el Nido sea un lugar seguro para recibir apoyo e inspiración. Ayúdenos a fomentar esta comunidad y respeta a todos en el Nido.\n\n"
        textBox.text = textBox.text + "Si encuentra algún contenido abusivo o que viola los términos, infórmelo al administrador de MotherWise.\n\n"
        //        textBox.text = textBox.text + "Please watch this video to see how to login: https://vimeo.com/430742850\n\n"
        textBox.text = textBox.text + "Si usted tiene cualquier pregunta, por favor póngase en contacto con nosotros:\n\n"
        textBox.text = textBox.text + "Correo electrónico: motherwisecolorado@gmail.com\n\n"
        textBox.text = textBox.text + "Número de teléfono: 720-504-4624"
        
    }
    
    @IBAction func agreeTerms(_ sender: Any) {
        self.showLoadingView()
        APIs.readTerms(member_id: thisUser.idx, handleCallback: {
            result in
            self.dismissLoadingView()
            if result == "0" {
                thisUser.status2 = "read_terms"
                if thisUser.registered_time.count == 0 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignupViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else if thisUser.address.count == 0 {
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHomeViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }else{
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewHomeViewController")
                    vc.modalPresentationStyle = .fullScreen
                    self.transitionVc(vc: vc, duration: 0.3, type: .fromRight)
                }
            }
        })
    }
    
}
