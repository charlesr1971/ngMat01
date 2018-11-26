import { Component, OnInit, OnDestroy, Inject, Renderer2 } from '@angular/core';
import { uuid } from './util/uuid';
import { DOCUMENT } from '@angular/common';
import { Router, NavigationEnd, Event } from '@angular/router';

import { CookieService } from 'ngx-cookie-service';

import { environment } from '../environments/environment';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit, OnDestroy {

  title: string = environment.title;
  cssClassName: string = '';
  debug: boolean = false;

  constructor(public cookieService: CookieService,
    @Inject(DOCUMENT) document,
    private router: Router,
    private renderer: Renderer2) { 

    this.router.events.subscribe((event: Event) => {
      if (event instanceof NavigationEnd) {
          if(this.debug) {
            console.log('app.componet: (<NavigationEnd>event).url ',(<NavigationEnd>event).url);
          }
          this.cssClassName = 'first-page';
          if((<NavigationEnd>event).url.indexOf('?') === -1){
            this.cssClassName = this.buildCssClassName((<NavigationEnd>event).url);
          }
          if(this.debug) {
            console.log('this.cssClassName',this.cssClassName);
          }
          this.renderer.setAttribute(document.body,'class',this.cssClassName);
      }
    });

  }

  ngOnInit(): void {
    
    //this.cookieService.set('userToken', "461caed9-38ab-4414-9513-c71d2040f7e3");
    if(!this.cookieService.check('userToken') || (this.cookieService.check('userToken') && this.cookieService.get('userToken') === '')) {
      this.cookieService.set('userToken', uuid());
      if(this.debug) {
        console.log('app.component: this.cookieService.get("userToken")',this.cookieService.get('userToken'));
      }
    }

  }

  buildCssClassName(url: string): string {
    return url.replace(/^\//,'').replace(/\/$/,'').replace(/\//g,'_').trim();
  }

  ngOnDestroy() {

  }

}
