function [tmptra] = reorderTra(otra)


  modelM.sensors.N=271;
    modelM.lead_field.model.sensors.N=555;
    

reorder_meg_ref_pos = [543:546 552 548 553 547 551 549 554 550 555];
  reorder_meg_ref_ori = [543:546 551 547 550 548 549 552:555];
  reorder_meg_ref_ori_sign = [-ones(298,1) ones(298,1) -ones(298,1) ...
  ones(298,1) -ones(298,1) ones(298,1) -ones(298,1) ones(298,1) ...
  -ones(298,1) ones(298,1) -ones(298,1) ones(298,1) -ones(298,1)];

  tmptra = [otra(:,1:modelM.sensors.N), -otra(:,modelM.sensors.N+1:2*(modelM.sensors.N)), otra(:,2*(modelM.sensors.N)+1:end)];
  tmptra = tmptra(:,[1:2*(modelM.sensors.N) reorder_meg_ref_pos]);
  tmptra = tmptra(:,[1:2*(modelM.sensors.N) reorder_meg_ref_ori]);
  tmptra = [tmptra(:,1:2*(modelM.sensors.N)), tmptra(:,543:end).*reorder_meg_ref_ori_sign];

end

