import { Component, OnInit } from '@angular/core';
import { uuid } from './util/uuid';

import { CookieService } from 'ngx-cookie-service';

import { environment } from '../environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  
  title = environment.title;

  constructor(public cookieService: CookieService) { 
  }

  ngOnInit(): void {
    
    if(!this.cookieService.check('userToken') || (this.cookieService.check('userToken') && this.cookieService.get('userToken') == '')) {
      this.cookieService.set('userToken', uuid());
      console.log("app.component: this.cookieService.get('userToken')",this.cookieService.get('userToken'));
    }

  }

}
