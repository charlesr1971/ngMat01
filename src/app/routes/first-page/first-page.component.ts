import { Component, OnInit } from '@angular/core';

import { Router, ActivatedRoute, Params } from '@angular/router';

import { Subscription } from 'rxjs/Subscription';

@Component({
  selector: 'app-first-page',
  templateUrl: './first-page.component.html',
  styleUrls: ['./first-page.component.css']
})
export class FirstPageComponent implements OnInit {

  private port: string;
  private cfid: string;
  private cftoken: string;
  private ngdomid: string;
  private sub: Subscription;

  debug: boolean = false;

  constructor(private router: Router,
    private route: ActivatedRoute) {

    this.sub = this.route.queryParams.subscribe((params: Params) => {
      if(this.debug) {
        console.log('first-page.component: params: ', params);
      }
      this.port = params['port'];
      this.cfid = params['cfid'];
      this.cftoken = params['cftoken'];
      this.ngdomid = params['ngdomid'];
      if(this.debug) {
        console.log('first-page.component: url variables: ', this.port, this.cfid, this.cftoken, this.ngdomid);
      }
    });

  }

  ngOnInit() {
  }

}
