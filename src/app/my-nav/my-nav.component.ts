import { Component, OnInit, OnDestroy } from '@angular/core';
import { BreakpointObserver, Breakpoints, BreakpointState } from '@angular/cdk/layout';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

import { HttpService } from '../services/http/http.service';
import { UtilsService } from '../services/utils/utils.service';

import { environment } from '../../environments/environment';

@Component({
  selector: 'app-my-nav',
  templateUrl: './my-nav.component.html',
  styleUrls: ['./my-nav.component.css']
})
export class MyNavComponent implements OnInit, OnDestroy {

  title = environment.title;
  pages = [];

  isHandset$: Observable<boolean> = this.breakpointObserver.observe(Breakpoints.Handset)
    .pipe(
      map(result => result.matches)
    );

  debug: boolean = false;
    
  constructor(private breakpointObserver: BreakpointObserver,
    private httpService: HttpService,
    private utilsService: UtilsService) {

      this.fetchData();

  }

  ngOnInit() {
  
  }

  fetchData(): void {
    this.httpService.fetchPages().subscribe( (data) => {
      if(!this.utilsService.isEmpty(data) && 'pages' in data) {
        for(var i = 0; i < data['pages']; i++) {
          let obj = {};
          obj['title'] = 'Section ' + (i + 1);
          this.pages.push(obj);
        }
      }
    });
  }

  onChange(event): void {
    const page = event.source.value;
    if(this.debug) {
      console.log('onChange: page: ', page);
    }
    this.httpService.galleryPage.next(page);
  }

  ngOnDestroy() {

  }
  
}
